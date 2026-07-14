import { onSchedule } from "firebase-functions/v2/scheduler";
import {
  getFirestore,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";
import { FUNCTION_REGION } from "./config";

// Most users are in the UAE (UTC+4, no DST); we roll each day up on that
// boundary so "today" matches the users' day. Run near end-of-day so every
// still-online device (last_seen within today) is counted — running after
// midnight would misattribute always-on TVs that beat past midnight.
const DUBAI_OFFSET_MS = 4 * 60 * 60 * 1000;

function pad(n: number): string {
  return n < 10 ? `0${n}` : `${n}`;
}

/// Writes one `daily_stats/{yyyy-MM-dd}` summary per day so the dashboard can
/// show history. Heartbeats are latest-only, so history only exists from the
/// day this starts running — it cannot backfill the past.
export const rollupDailyStats = onSchedule(
  {
    schedule: "50 23 * * *",
    timeZone: "Asia/Dubai",
    region: FUNCTION_REGION,
    memory: "256MiB",
  },
  async () => {
    const db = getFirestore();
    const shifted = new Date(Date.now() + DUBAI_OFFSET_MS);
    const y = shifted.getUTCFullYear();
    const m = shifted.getUTCMonth();
    const d = shifted.getUTCDate();
    const dayStartMs = Date.UTC(y, m, d, 0, 0, 0) - DUBAI_OFFSET_MS;
    const dayStart = Timestamp.fromMillis(dayStartMs);
    const dateStr = `${y}-${pad(m + 1)}-${pad(d)}`;

    // Active devices today: heartbeat is latest-only, so a device counts if its
    // last beat lands within today's window.
    const hb = await db
      .collection("device_heartbeats")
      .where("last_seen", ">=", dayStart)
      .select("selected_country", "app_version")
      .get();
    const byCountry: Record<string, number> = {};
    const byVersion: Record<string, number> = {};
    hb.forEach((doc) => {
      const x = doc.data();
      const c = (x.selected_country as string) || "unknown";
      const v = (x.app_version as string) || "unknown";
      byCountry[c] = (byCountry[c] || 0) + 1;
      byVersion[v] = (byVersion[v] || 0) + 1;
    });

    // Prayer cycles today (date_key is the device-local day, "yyyy-MM-dd").
    const fr = await db
      .collection("flow_runs")
      .where("date_key", "==", dateStr)
      .select("result", "flow")
      .get();
    let cyclesOk = 0;
    let cyclesFail = 0;
    let adhanOk = 0;
    let iqamaOk = 0;
    fr.forEach((doc) => {
      const x = doc.data();
      const ok = x.result === "success";
      if (ok) cyclesOk++;
      else if (x.result === "failure") cyclesFail++;
      if (ok && x.flow === "adhan") adhanOk++;
      if (ok && x.flow === "iqama") iqamaOk++;
    });

    // Errors today — a single-field range read (no composite index needed).
    const err = await db
      .collection("error_events")
      .where("created_at", ">=", dayStart)
      .select("severity")
      .get();
    let fatal = 0;
    err.forEach((doc) => {
      if (doc.data().severity === "fatal") fatal++;
    });

    await db
      .collection("daily_stats")
      .doc(dateStr)
      .set(
        {
          date: dateStr,
          active_devices: hb.size,
          by_country: byCountry,
          by_version: byVersion,
          cycles_ok: cyclesOk,
          cycles_fail: cyclesFail,
          adhan_ok: adhanOk,
          iqama_ok: iqamaOk,
          errors: err.size,
          fatal: fatal,
          generated_at: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
  },
);
