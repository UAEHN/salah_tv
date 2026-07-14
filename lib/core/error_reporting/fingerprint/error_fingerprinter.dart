import 'dart:convert';

import 'stack_frame_parser.dart';

/// FNV-1a 64-bit hex digest. Deliberately implemented with [BigInt] so the
/// Cloud Functions TypeScript mirror (BigInt as well) produces bit-identical
/// fingerprints — both sides share the same test vectors.
String fnv1a64Hex(String input) {
  final mask = BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16);
  final prime = BigInt.parse('100000001b3', radix: 16);
  var hash = BigInt.parse('cbf29ce484222325', radix: 16);
  for (final byte in utf8.encode(input)) {
    hash = hash ^ BigInt.from(byte);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

/// Builds the grouping fingerprint for an error record.
///
/// With an app frame: `errorType|category|file|member` — the line number is
/// deliberately EXCLUDED (lines churn every release and would fragment
/// groups). Without an app frame (framework-only stacks such as layout
/// overflows): `errorType|category|normalized message head|route`, where
/// digits are stripped so "overflowed by 42 pixels" and "by 17 pixels"
/// group together.
class ErrorFingerprinter {
  const ErrorFingerprinter();

  static const int _messageHeadLength = 120;

  String fingerprint({
    required String errorType,
    required String category,
    required String message,
    required String route,
    AppStackFrame? topFrame,
  }) {
    final key = topFrame != null
        ? '$errorType|$category|${topFrame.file}|${topFrame.member}'
        : '$errorType|$category|${normalizeMessage(message)}|$route';
    return fnv1a64Hex(key);
  }

  /// Silent failures group by flow + failed step; the prayer name stays a
  /// field (grouping per prayer would fragment one defect into five groups).
  String silentFailureFingerprint({
    required String flow,
    required String failedStep,
  }) {
    return fnv1a64Hex('silent_failure|$flow|$failedStep');
  }

  /// Native (JVM) crashes group by error type + top native frame — the frame's
  /// line is excluded (it churns per build). Mirrored in the Cloud Functions
  /// `fingerprint.ts`.
  String nativeCrashFingerprint({
    required String errorType,
    required String topFrame,
  }) {
    return fnv1a64Hex('native_crash|$errorType|$topFrame');
  }

  /// Digits → `#`, whitespace collapsed, head truncated — keeps messages
  /// with embedded sizes/ids/timestamps in one group.
  static String normalizeMessage(String message) {
    var head = message.length > _messageHeadLength
        ? message.substring(0, _messageHeadLength)
        : message;
    head = head.replaceAll(RegExp(r'\d+'), '#');
    return head.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
