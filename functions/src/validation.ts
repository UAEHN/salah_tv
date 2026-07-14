import { DocumentData } from "firebase-admin/firestore";
import { CleanErrorEvent } from "./types";

const KINDS = ["exception", "silent_failure", "native_crash"];
const SEVERITIES = ["info", "warning", "error", "fatal"];

function str(value: unknown, fallback = ""): string {
  return typeof value === "string" ? value : fallback;
}

// Sanitizes a raw error_events doc into a CleanErrorEvent, or null if it fails
// the kind/severity whitelist. The security rules already gate writes, but the
// pipeline re-validates (defense in depth) and truncation caps group fields so
// one oversized event can't bloat a group doc.
export function validateEvent(
  eventId: string,
  raw: DocumentData | undefined,
): CleanErrorEvent | null {
  if (!raw) return null;
  const kind = str(raw.kind);
  const severity = str(raw.severity);
  if (!KINDS.includes(kind) || !SEVERITIES.includes(severity)) return null;

  const origin = (raw.origin ?? {}) as Record<string, unknown>;
  const app = (raw.app ?? {}) as Record<string, unknown>;
  const flowRaw = raw.flow as Record<string, unknown> | undefined;
  const breadcrumbs = Array.isArray(raw.breadcrumbs) ? raw.breadcrumbs : [];

  return {
    eventId,
    kind: kind as CleanErrorEvent["kind"],
    severity: severity as CleanErrorEvent["severity"],
    name: str(raw.name, "unknown").slice(0, 200),
    errorType: str(raw.error_type, "Unknown").slice(0, 200),
    message: str(raw.message).slice(0, 2048),
    category: str(raw.category, "Unknown").slice(0, 80),
    origin: {
      file: str(origin.file, "unknown").slice(0, 300),
      member: str(origin.member, "unknown").slice(0, 200),
      line: typeof origin.line === "number" ? origin.line : undefined,
    },
    route: str(raw.route).slice(0, 300),
    flow: flowRaw
      ? { flow: str(flowRaw.flow), failed_step: str(flowRaw.failed_step) }
      : undefined,
    appVersion: str(app.version, "unknown").slice(0, 40),
    installId: str(app.install_id, "unknown").slice(0, 100),
    likelyCause: str(raw.likely_cause) || undefined,
    stackHead: str(raw.stack).slice(0, 500),
    breadcrumbTail: breadcrumbs.slice(-5),
  };
}
