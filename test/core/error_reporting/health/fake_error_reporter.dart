import 'package:ghasaq/core/error_reporting/domain/breadcrumb.dart';
import 'package:ghasaq/core/error_reporting/domain/error_severity.dart';
import 'package:ghasaq/core/error_reporting/domain/i_error_reporting_service.dart';

/// Captures every silent failure / error reported, for assertions.
class CapturedIncident {
  CapturedIncident({
    required this.name,
    required this.flow,
    required this.prayerKey,
    required this.failedStep,
    required this.stepsCompleted,
    required this.waitedMs,
    required this.severity,
    this.secondsPlayed,
    this.expected,
    this.actual,
    this.message,
    this.evidence,
  });

  final String name;
  final String flow;
  final String prayerKey;
  final String failedStep;
  final List<String> stepsCompleted;
  final int waitedMs;
  final ErrorSeverity severity;
  final int? secondsPlayed;
  final String? expected;
  final String? actual;
  final String? message;
  final Map<String, Object?>? evidence;
}

/// Captures a native-crash report for assertions.
class CapturedNativeCrash {
  CapturedNativeCrash({
    required this.errorType,
    required this.message,
    required this.stack,
    required this.breadcrumbs,
    this.crashAt,
  });

  final String errorType;
  final String message;
  final String stack;
  final List<Breadcrumb> breadcrumbs;
  final DateTime? crashAt;
}

class FakeErrorReporter implements IErrorReportingService {
  final List<CapturedIncident> incidents = [];
  final List<CapturedNativeCrash> nativeCrashes = [];

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
  }) {
    incidents.add(
      CapturedIncident(
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
  }

  @override
  void reportError({
    required String name,
    required Object error,
    StackTrace? stack,
    ErrorSeverity severity = ErrorSeverity.error,
    String? categoryOverride,
    Map<String, Object?>? extra,
  }) {}

  @override
  void reportNativeCrash({
    required String errorType,
    required String message,
    required String stack,
    required List<Breadcrumb> breadcrumbs,
    DateTime? crashAt,
  }) {
    nativeCrashes.add(
      CapturedNativeCrash(
        errorType: errorType,
        message: message,
        stack: stack,
        breadcrumbs: breadcrumbs,
        crashAt: crashAt,
      ),
    );
  }

  @override
  Future<void> initialize() async {}

  @override
  void setDeviceId(String deviceId) {}

  @override
  void setContext(Map<String, Object?> values) {}

  @override
  Future<void> dispose() async {}
}
