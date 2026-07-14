import 'dart:async';

import 'telemetry_event.dart';

/// In-process broadcast of every diagnostic/analytics event. The existing
/// sinks publish here with one synchronous line each; subscribers
/// (BreadcrumbRecorder now, FunctionalHealthMonitor in Phase 2) observe the
/// whole app without new ports on the prayer engine.
///
/// [publish] is called from hot paths (engine telemetry) and MUST never
/// throw or block — it is fully guarded and purely synchronous.
class TelemetryBus {
  final StreamController<TelemetryEvent> _controller =
      StreamController<TelemetryEvent>.broadcast();

  Stream<TelemetryEvent> get events => _controller.stream;

  void publish({
    required String source,
    required String name,
    String? level,
    Map<String, Object?> params = const {},
    DateTime? at,
  }) {
    try {
      if (_controller.isClosed) return;
      _controller.add(
        TelemetryEvent(
          source: source,
          name: name,
          level: level,
          params: params,
          at: at ?? DateTime.now(),
        ),
      );
    } catch (_) {
      // Telemetry must never break the caller (§8 CLAUDE.md).
    }
  }

  /// App-lifetime singleton — only closed in tests.
  Future<void> dispose() async {
    try {
      await _controller.close();
    } catch (_) {}
  }
}
