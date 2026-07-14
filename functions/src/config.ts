import { defineSecret } from "firebase-functions/params";

// Telegram bot credentials — set once (never committed) via:
//   firebase functions:secrets:set TELEGRAM_BOT_TOKEN
//   firebase functions:secrets:set TELEGRAM_CHAT_ID
export const telegramBotToken = defineSecret("TELEGRAM_BOT_TOKEN");
export const telegramChatId = defineSecret("TELEGRAM_CHAT_ID");

// The function runs in Europe to match the eur3 (Europe multi-region) Firestore
// location of project ghasaq-75883 — a Firestore trigger must live in the
// database's location. Migrate both together if the DB ever moves.
export const FUNCTION_REGION = "europe-west1";

// Deep-link base for alert messages (the Control Room web app, Phase 4).
export const DASHBOARD_URL = "https://ghasaq-75883.web.app";

export const Thresholds = {
  spikeMinCount: 10, // ≥10 events in the current hour bucket, AND
  spikeAvgMultiple: 5, // ≥5× the trailing hourly average → a spike
  alertCooldownMs: 6 * 60 * 60 * 1000, // 6h between repeat alerts per group
  maxOccurrences: 50,
  maxVersions: 15,
  maxRoutes: 10,
  maxHourlyBuckets: 25,
  occurrenceTrimEvery: 20, // amortize the occurrences trim (not every event)
} as const;
