/** The sanitized shape of an `error_events` doc the pipeline works with —
 *  produced by validation.ts, never trusts raw client input beyond this. */
export interface CleanErrorEvent {
  eventId: string;
  kind: "exception" | "silent_failure" | "native_crash";
  severity: "info" | "warning" | "error" | "fatal";
  name: string;
  errorType: string;
  message: string;
  category: string;
  origin: { file: string; member: string; line?: number };
  route: string;
  flow?: { flow: string; failed_step: string };
  appVersion: string;
  installId: string;
  likelyCause?: string;
  stackHead: string;
  breadcrumbTail: unknown[];
}

export type AlertReason = "new" | "spike" | "reopen" | null;

/** What upsertErrorGroup tells the alerter after the group transaction. */
export interface AlertDecision {
  fingerprint: string;
  reason: AlertReason;
  severity: string;
  name: string;
  category: string;
  count: number;
  appVersion: string;
  route: string;
  lastAlertAtMs: number | null;
}
