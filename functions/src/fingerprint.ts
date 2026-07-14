import { CleanErrorEvent } from "./types";

/// FNV-1a 64-bit hex digest — a BigInt mirror of the Dart `fnv1a64Hex`
/// (lib/core/error_reporting/fingerprint/error_fingerprinter.dart). Both sides
/// share the vectors in fingerprint.test.ts; changing either without the other
/// silently fragments every group.
export function fnv1a64Hex(input: string): string {
  const mask = (1n << 64n) - 1n;
  const prime = 0x100000001b3n;
  let hash = 0xcbf29ce484222325n;
  for (const byte of Buffer.from(input, "utf8")) {
    hash ^= BigInt(byte);
    hash = (hash * prime) & mask;
  }
  return hash.toString(16).padStart(16, "0");
}

/// Digits → `#`, whitespace collapsed, head truncated — mirror of Dart
/// `ErrorFingerprinter.normalizeMessage`.
export function normalizeMessage(message: string): string {
  let head = message.length > 120 ? message.slice(0, 120) : message;
  head = head.replace(/\d+/g, "#");
  return head.replace(/\s+/g, " ").trim();
}

/// Recomputes the grouping fingerprint server-side (never trusts the client's
/// `fingerprint` field). Mirrors every Dart branch exactly:
///   silent_failure → silent_failure|flow|failed_step
///   native_crash   → native_crash|errorType|file.member
///   exception w/ app frame  → errorType|category|file|member
///   exception w/o app frame → errorType|category|normalizedMessage|route
export function fingerprintForEvent(e: CleanErrorEvent): string {
  if (e.kind === "silent_failure") {
    const flow = e.flow?.flow || "unknown";
    const step = e.flow?.failed_step || "unknown";
    return fnv1a64Hex(`silent_failure|${flow}|${step}`);
  }
  if (e.kind === "native_crash") {
    return fnv1a64Hex(
      `native_crash|${e.errorType}|${e.origin.file}.${e.origin.member}`,
    );
  }
  const hasFrame = !(e.origin.file === "unknown" && e.origin.member === "unknown");
  const key = hasFrame
    ? `${e.errorType}|${e.category}|${e.origin.file}|${e.origin.member}`
    : `${e.errorType}|${e.category}|${normalizeMessage(e.message)}|${e.route}`;
  return fnv1a64Hex(key);
}
