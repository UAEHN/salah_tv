import 'breadcrumb.dart';
import 'error_severity.dart';

/// Central error-observability port. All capture paths (global hooks, Dio
/// interceptor, functional-health monitor, native crash bridge) report
/// through this interface; implementations enrich, queue offline, and upload
/// to Firestore `error_events`.
///
/// Contract: every method is fire-and-forget and MUST swallow its own
/// failures — the reporting pipeline can never crash the app (§8 CLAUDE.md).
abstract class IErrorReportingService {
  Future<void> initialize();

  /// Reports a caught/uncaught exception with full context enrichment.
  void reportError({
    required String name,
    required Object error,
    StackTrace? stack,
    ErrorSeverity severity = ErrorSeverity.error,
    String? categoryOverride,
    Map<String, Object?>? extra,
  });

  /// Reports a functional-health silent failure (a critical behavior that
  /// did not happen — no exception was thrown). Used by Phase 2's
  /// FunctionalHealthMonitor; the signature is stable from Phase 1.
  void reportSilentFailure({
    required String name,
    required String flow,
    required String prayerKey,
    required String failedStep,
    required List<String> stepsCompleted,
    required int waitedMs,
    required ErrorSeverity severity,
    int? secondsPlayed,
    String? expected,
    String? actual,
    String? message,
    Map<String, Object?>? evidence,
  });

  /// Reports a JVM-level native crash recovered from the previous session's
  /// marker on boot, filed as `kind='native_crash'` and carrying that
  /// session's [breadcrumbs] trail. Fatal by nature (it killed the process).
  void reportNativeCrash({
    required String errorType,
    required String message,
    required String stack,
    required List<Breadcrumb> breadcrumbs,
    DateTime? crashAt,
  });

  /// Stable install id — the join key across heartbeats/diagnostics/errors.
  void setDeviceId(String deviceId);

  /// Cross-cutting settings context (city/country/modes) attached to every
  /// subsequent record.
  void setContext(Map<String, Object?> values);

  Future<void> dispose();
}
