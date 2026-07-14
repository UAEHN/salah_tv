import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/bus/telemetry_bus.dart';
import 'package:ghasaq/core/error_reporting/bus/telemetry_event.dart';
import 'package:ghasaq/core/error_reporting/health/countdown_stall_detector.dart';
import 'package:ghasaq/core/error_reporting/health/flow_outcome.dart';
import 'package:ghasaq/core/error_reporting/health/functional_health_monitor.dart';
import 'package:ghasaq/core/error_reporting/health/health_state_store.dart';
import 'package:ghasaq/core/error_reporting/health/sequence_integrity_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_error_reporter.dart';

class _NullFlowRunSink implements FlowRunSink {
  @override
  void record(FlowOutcome outcome, {required bool silentMode}) {}
}

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TelemetryBus bus;
  late FakeErrorReporter reporter;
  late FunctionalHealthMonitor monitor;

  Future<void> boot() async {
    SharedPreferences.setMockInitialValues({});
    bus = TelemetryBus();
    reporter = FakeErrorReporter();
    monitor = FunctionalHealthMonitor(
      reporter: reporter,
      sequenceChecker: SequenceIntegrityChecker(
        reporter: reporter,
        store: HealthStateStore(),
        sessionId: 's1',
        clock: () => DateTime(2026, 7, 8, 12),
      ),
      stallDetector: CountdownStallDetector(reporter: reporter),
      flowRunSink: _NullFlowRunSink(),
    );
    await monitor.start(bus);
  }

  tearDown(() async {
    await monitor.dispose();
    await bus.dispose();
  });

  void iqamaJourney(String state) => bus.publish(
        source: TelemetrySource.analytics,
        name: 'prayer_alert_journey_state',
        params: {
          'alert_type': 'iqama',
          'prayer_key': 'dhuhr',
          'final_state': state,
        },
      );

  void iqamaCompleted({required int seconds, required bool stoppedByUser}) =>
      bus.publish(
        source: TelemetrySource.analytics,
        name: 'iqama_completed',
        params: {
          'prayer_key': 'dhuhr',
          'duration_seconds': seconds,
          'was_natural': 'true',
          'stopped_by_user': stoppedByUser.toString(),
        },
      );

  bool hasTruncationIncident() =>
      reporter.incidents.any((i) => i.name == 'iqama_audio_truncated');

  test('a user-skipped short iqama does NOT report truncation', () async {
    await boot();
    iqamaJourney('FIRED');
    await _tick();
    iqamaJourney('AUDIO_STARTED'); // records the audio-start moment
    await _tick();
    iqamaCompleted(seconds: 3, stoppedByUser: true); // user pressed select
    await _tick();
    expect(hasTruncationIncident(), isFalse,
        reason: 'a remote-skip is intentional, not a decode failure');
  });

  test('a genuinely short iqama (not user-stopped) DOES report truncation',
      () async {
    await boot();
    iqamaJourney('FIRED');
    await _tick();
    iqamaJourney('AUDIO_STARTED');
    await _tick();
    iqamaCompleted(seconds: 3, stoppedByUser: false); // audio died early
    await _tick();
    expect(hasTruncationIncident(), isTrue,
        reason: 'a real early death must still be caught');
  });
}
