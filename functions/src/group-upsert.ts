import { DocumentData, FieldValue, Firestore } from "firebase-admin/firestore";
import { AlertDecision, AlertReason, CleanErrorEvent } from "./types";
import { Thresholds } from "./config";
import {
  bumpHourly,
  hourBucket,
  isSpike,
  maxSeverity,
  unionCapped,
} from "./group-helpers";

function lastEvent(e: CleanErrorEvent, nowMs: number): DocumentData {
  return {
    event_id: e.eventId,
    at: nowMs, // number, not serverTimestamp — the latter is illegal in a map
    install_id: e.installId,
    app_version: e.appVersion,
    route: e.route,
    stack_head: e.stackHead,
    breadcrumb_tail: e.breadcrumbTail,
  };
}

function occurrence(e: CleanErrorEvent, nowMs: number): DocumentData {
  return {
    event_id: e.eventId,
    at: nowMs,
    install_id: e.installId,
    app_version: e.appVersion,
    severity: e.severity,
    route: e.route,
  };
}

function decision(
  fingerprint: string,
  reason: AlertReason,
  e: CleanErrorEvent,
  count: number,
  lastAlertAtMs: number | null,
): AlertDecision {
  return {
    fingerprint,
    reason,
    severity: e.severity,
    name: e.name,
    category: e.category,
    count,
    appVersion: e.appVersion,
    route: e.route,
    lastAlertAtMs,
  };
}

// Transactionally upserts error_groups/{fingerprint} for one event and writes
// its occurrence pointer, returning what (if anything) to alert on. Reads
// before writes (Firestore transaction rule).
export async function upsertErrorGroup(
  db: Firestore,
  e: CleanErrorEvent,
  fingerprint: string,
  nowMs: number,
): Promise<AlertDecision> {
  const groupRef = db.collection("error_groups").doc(fingerprint);
  const occRef = groupRef.collection("occurrences").doc(e.eventId);
  const hour = hourBucket(nowMs);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(groupRef);
    tx.set(occRef, occurrence(e, nowMs));

    if (!snap.exists) {
      tx.set(groupRef, {
        fingerprint,
        kind: e.kind,
        name: e.name,
        error_type: e.errorType,
        category: e.category,
        origin: e.origin,
        flow: e.flow ?? null,
        severity: e.severity,
        message: e.message,
        likely_cause: e.likelyCause ?? null,
        llm_hint: null,
        first_seen: FieldValue.serverTimestamp(),
        last_seen: FieldValue.serverTimestamp(),
        count: 1,
        versions: e.appVersion ? [e.appVersion] : [],
        routes: e.route ? [e.route] : [],
        counts_hourly: { [hour]: 1 },
        status: "open",
        reopened_count: 0,
        last_alert_at: null,
        last_event: lastEvent(e, nowMs),
      });
      return decision(fingerprint, "new", e, 1, null);
    }

    const g = snap.data() as DocumentData;
    const count = ((g.count as number) ?? 0) + 1;
    const counts = bumpHourly(
      (g.counts_hourly ?? {}) as Record<string, number>,
      hour,
      Thresholds.maxHourlyBuckets,
    );
    const wasResolved = g.status === "resolved";
    const spike = isSpike(
      counts,
      hour,
      Thresholds.spikeMinCount,
      Thresholds.spikeAvgMultiple,
    );

    tx.update(groupRef, {
      last_seen: FieldValue.serverTimestamp(),
      count,
      flow: e.flow ?? g.flow ?? null,
      severity: maxSeverity(
        typeof g.severity === "string" ? g.severity : "info",
        e.severity,
      ),
      message: e.message,
      likely_cause: e.likelyCause ?? g.likely_cause ?? null,
      versions: unionCapped(
        g.versions as string[] | undefined,
        e.appVersion,
        Thresholds.maxVersions,
      ),
      routes: unionCapped(
        g.routes as string[] | undefined,
        e.route,
        Thresholds.maxRoutes,
      ),
      counts_hourly: counts,
      status: wasResolved ? "open" : (g.status ?? "open"),
      reopened_count: wasResolved
        ? ((g.reopened_count as number) ?? 0) + 1
        : ((g.reopened_count as number) ?? 0),
      last_event: lastEvent(e, nowMs),
    });

    const reason: AlertReason = wasResolved ? "reopen" : spike ? "spike" : null;
    return decision(
      fingerprint,
      reason,
      e,
      count,
      (g.last_alert_at as number | null) ?? null,
    );
  });
}
