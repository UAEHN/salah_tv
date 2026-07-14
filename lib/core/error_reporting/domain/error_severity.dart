import '../../diagnostics/diagnostic_level.dart';

/// Severity of a reported error record. [wireName] is the exact string stored
/// in Firestore `error_events.severity` and validated by the security rules —
/// changing a value is a schema change, not a rename.
enum ErrorSeverity {
  info,
  warning,
  error,
  fatal;

  String get wireName => name;

  static ErrorSeverity fromDiagnosticLevel(DiagnosticLevel level) {
    return switch (level) {
      DiagnosticLevel.debug || DiagnosticLevel.info => ErrorSeverity.info,
      DiagnosticLevel.warning => ErrorSeverity.warning,
      DiagnosticLevel.error => ErrorSeverity.error,
      DiagnosticLevel.fatal => ErrorSeverity.fatal,
    };
  }
}
