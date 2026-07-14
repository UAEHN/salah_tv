import { Firestore } from "firebase-admin/firestore";
import { AlertDecision } from "../types";
import { DASHBOARD_URL, Thresholds } from "../config";
import { SEVERITY_RANK } from "../group-helpers";
import { sendTelegram } from "./telegram";

const REASON_LABEL: Record<string, string> = {
  new: "NEW",
  spike: "SPIKE",
  reopen: "REOPENED",
};

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function buildMessage(d: AlertDecision): string {
  return [
    `<b>[${d.severity.toUpperCase()}] ${REASON_LABEL[d.reason ?? "new"]}</b>`,
    `${escapeHtml(d.name)} — ${escapeHtml(d.category)}`,
    `count: ${d.count} · v${escapeHtml(d.appVersion)}`,
    `route: ${escapeHtml(d.route || "—")}`,
    `${DASHBOARD_URL}?fp=${d.fingerprint}`,
  ].join("\n");
}

// Decides whether a group change warrants a Telegram alert and, if so, sends it
// and stamps last_alert_at. Rules: a brand-new group alerts only at severity ≥
// error; spikes/reopens always qualify but honor the 6h per-group cooldown.
export async function maybeSendAlert(
  db: Firestore,
  d: AlertDecision,
  nowMs: number,
): Promise<void> {
  if (!d.reason) return;
  if (
    d.reason === "new" &&
    (SEVERITY_RANK[d.severity] ?? 0) < SEVERITY_RANK.error
  ) {
    return;
  }
  if (
    d.reason !== "new" &&
    d.lastAlertAtMs !== null &&
    nowMs - d.lastAlertAtMs < Thresholds.alertCooldownMs
  ) {
    return;
  }
  const sent = await sendTelegram(buildMessage(d));
  if (sent) {
    await db
      .collection("error_groups")
      .doc(d.fingerprint)
      .update({ last_alert_at: nowMs });
  }
}
