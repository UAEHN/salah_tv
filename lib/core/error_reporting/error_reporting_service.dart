import 'dart:async';

import 'context/error_context_collector.dart';
import 'domain/breadcrumb.dart';
import 'domain/error_record.dart';
import 'domain/error_severity.dart';
import 'domain/i_error_reporting_service.dart';
import 'error_record_builder.dart';
import 'error_record_sink.dart';
import 'native/native_crash_record_builder.dart';

/// Orchestrates capture → enrich → persist. Never-crash discipline: every
/// public method is fire-and-forget and fully guarded; the service never
/// reports its own faults through itself (a debug-only counter tracks them
/// instead), so a bug here can neither crash the app nor recurse. The durable
/// tail (rate-limit → queue → flush) lives in [ErrorRecordSink].
class ErrorReportingService implements IErrorReportingService {
  ErrorReportingService({
    required ErrorRecordBuilder builder,
    required NativeCrashRecordBuilder nativeCrashBuilder,
    required ErrorRecordSink sink,
    required ErrorContextCollector collector,
  }) : _builder = builder,
       _nativeCrashBuilder = nativeCrashBuilder,
       _sink = sink,
       _collector = collector;

  final ErrorRecordBuilder _builder;
  final NativeCrashRecordBuilder _nativeCrashBuilder;
  final ErrorRecordSink _sink;
  final ErrorContextCollector _collector;

  /// Faults inside the reporting pipeline itself (visible on the debug
  /// test screen; intentionally never re-reported — loop guard).
  int selfErrorCount = 0;

  @override
  Future<void> initialize() async {
    // Collaborators are wired by startup_error_reporting; the port contract
    // keeps this hook for symmetry.
  }

  @override
  void reportError({
    required String name,
    required Object error,
    StackTrace? stack,
    ErrorSeverity severity = ErrorSeverity.error,
    String? categoryOverride,
    Map<String, Object?>? extra,
  }) => _report(
    () => _builder.buildException(
      name: name,
      error: error,
      stack: stack,
      severity: severity,
      categoryOverride: categoryOverride,
      extra: extra,
    ),
  );

  @override
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
  }) => _report(
    () => _builder.buildSilentFailure(
      name: name,
      flow: flow,
      prayerKey: prayerKey,
      failedStep: failedStep,
      stepsCompleted: stepsCompleted,
      waitedMs: waitedMs,
      severity: severity,
      secondsPlayed: secondsPlayed,
      expected: expected,
      actual: actual,
      message: message,
      evidence: evidence,
    ),
  );

  @override
  void reportNativeCrash({
    required String errorType,
    required String message,
    required String stack,
    required List<Breadcrumb> breadcrumbs,
    DateTime? crashAt,
  }) => _report(
    () => _nativeCrashBuilder.build(
      errorType: errorType,
      message: message,
      stack: stack,
      breadcrumbs: breadcrumbs,
      crashAt: crashAt,
    ),
  );

  /// Shared tail for every capture path: build (guarded) then persist once.
  void _report(Future<ErrorRecord> Function() build) {
    unawaited(_guarded(() async => _sink.persist(await build())));
  }

  @override
  void setDeviceId(String deviceId) {
    try {
      _collector.installId = deviceId;
    } catch (_) {}
  }

  @override
  void setContext(Map<String, Object?> values) {
    try {
      _collector.setSettingsContext(values);
    } catch (_) {}
  }

  @override
  Future<void> dispose() => _sink.dispose();

  Future<void> _guarded(Future<void> Function() body) async {
    try {
      await body();
    } catch (_) {
      selfErrorCount++;
    }
  }
}
