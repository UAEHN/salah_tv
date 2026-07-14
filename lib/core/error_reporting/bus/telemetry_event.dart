/// Origin of a [TelemetryEvent]. Subscribers use this to avoid feedback
/// loops: anything published by the error-reporting pipeline itself is
/// ignored by breadcrumbs and (Phase 2) the functional-health monitor.
class TelemetrySource {
  const TelemetrySource._();

  static const String diag = 'diag';
  static const String analytics = 'analytics';
  static const String errorReporting = 'error_reporting';
}

/// One in-process telemetry event mirrored off the existing sinks
/// ([AppDiagnostics.record] / FirebaseAnalytics `logEventInternal`) onto the
/// [TelemetryBus]. Carries no behavior — a pure value.
class TelemetryEvent {
  const TelemetryEvent({
    required this.source,
    required this.name,
    required this.at,
    this.level,
    this.params = const {},
  });

  final String source;
  final String name;
  final String? level;
  final Map<String, Object?> params;
  final DateTime at;
}
