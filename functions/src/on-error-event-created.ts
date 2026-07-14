import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import {
  FUNCTION_REGION,
  Thresholds,
  telegramBotToken,
  telegramChatId,
} from "./config";
import { validateEvent } from "./validation";
import { fingerprintForEvent } from "./fingerprint";
import { upsertErrorGroup } from "./group-upsert";
import { trimOccurrences } from "./occurrences";
import { maybeSendAlert } from "./alerting/alert-sender";

initializeApp();
const db = getFirestore();
// The Admin SDK rejects `undefined` field values (unlike the Flutter client
// that wrote the event). Client records legitimately omit optional fields
// (origin.line, flow, …), so ignore undefined rather than throw mid-upsert.
db.settings({ ignoreUndefinedProperties: true });

// Fires on every new error_events doc: validate → recompute the fingerprint
// server-side (never trust the client) → transactionally upsert its
// error_groups doc + occurrence → amortized occurrences trim → alert decision.
export const onErrorEventCreated = onDocumentCreated(
  {
    document: "error_events/{eventId}",
    region: FUNCTION_REGION,
    secrets: [telegramBotToken, telegramChatId],
    memory: "256MiB",
    retry: false,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const clean = validateEvent(snap.id, snap.data());
    if (!clean) return;

    const fingerprint = fingerprintForEvent(clean);
    const nowMs = Date.now();
    const decision = await upsertErrorGroup(db, clean, fingerprint, nowMs);

    if (decision.count % Thresholds.occurrenceTrimEvery === 0) {
      await trimOccurrences(db, fingerprint, Thresholds.maxOccurrences);
    }
    await maybeSendAlert(db, decision, nowMs);
  },
);
