import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/bus/telemetry_bus.dart';
import 'package:ghasaq/core/error_reporting/bus/telemetry_event.dart';
import 'package:ghasaq/core/error_reporting/domain/error_severity.dart';
import 'package:ghasaq/core/error_reporting/health/countdown_stall_detector.dart';
import 'package:ghasaq/core/error_reporting/health/flow_definitions.dart';
import 'package:ghasaq/core/error_reporting/health/flow_outcome.dart';
import 'package:ghasaq/core/error_reporting/health/functional_health_monitor.dart';
import 'package:ghasaq/core/error_reporting/health/health_state_store.dart';
import 'package:ghasaq/core/error_reporting/health/sequence_integrity_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_error_reporter.dart';

class _FakeFlowRunSink implements FlowRunSink {
  final List<FlowOutcome> runs = [];
  @override
  void record(FlowOutcome outcome, {required bool silentMode}) =>
      runs.add(outcome);
}

/// Emits an adhan journey state onto the bus exactly as the analytics tap does.
void _adhan(TelemetryBus bus, String state, {String prayer = 'dhuhr'}) =>
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'adhan_journey_state',
      params: {'prayer_key': prayer, 'adhan_final_state': state},
    );

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TelemetryBus bus;
  late FakeErrorReporter reporter;
  late _FakeFlowRunSink sink;
  late FunctionalHealthMonitor monitor;

  Future<void> boot() async {
    SharedPreferences.setMockInitialValues({});
    bus = TelemetryBus();
    reporter = FakeErrorReporter();
    sink = _FakeFlowRunSink();
    monitor = FunctionalHealthMonitor(
      reporter: reporter,
      sequenceChecker: SequenceIntegrityChecker(
        reporter: reporter,
        store: HealthStateStore(),
        sessionId: 's1',
        clock: () => DateTime(2026, 7, 3, 12),
      ),
      stallDetector: CountdownStallDetector(reporter: reporter),
      flowRunSink: sink,
    );
    await monitor.start(bus);
  }

  tearDown(() async {
    await monitor.dispose();
    await bus.dispose();
  });

  test('full adhan funnel → success flow run, no incident', () async {
    await boot();
    _adhan(bus, 'FIRED');
    await _tick();
    bus.publish(
      source: TelemetrySource.diag,
      name: 'alert_screen_rendered',
      params: {'flow': 'adhan', 'prayer_key': 'dhuhr'},
    );
    await _tick();
    _adhan(bus, 'AUDIO_STARTED');
    await _tick();
    _adhan(bus, 'AUDIO_COMPLETED');
    await _tick();
    expect(sink.runs.single.result, FlowResult.success);
    expect(reporter.incidents, isEmpty);
  });

  test('loop guard: error_reporting-sourced events are ignored', () async {
    await boot();
    bus.publish(
      source: TelemetrySource.errorReporting,
      name: 'adhan_journey_state',
      params: {'prayer_key': 'dhuhr', 'adhan_final_state': 'FIRED'},
    );
    await _tick();
    expect(sink.runs, isEmpty);
  });

  // Engine ticking continuously since t0; prayer fell at t0+60s; overdue
  // detected 120s later. The heartbeat proves the engine was alive THROUGH the
  // prayer, so the miss is a real failure.
  final t0 = DateTime(2026, 7, 6, 5);
  void heartbeatAt(DateTime at) => bus.publish(
    source: TelemetrySource.analytics,
    name: 'tick_heartbeat',
    params: const {'next_prayer_key': 'maghrib'},
    at: at,
  );
  void overdueAt(DateTime at, {String prayer = 'maghrib', int seconds = 120}) =>
      bus.publish(
        source: TelemetrySource.analytics,
        name: 'prayer_overdue_no_trigger',
        params: {
          'prayer_key': prayer,
          'overdue_seconds': seconds,
          'adhan_mode': 'sound',
        },
        at: at,
      );

  test('overdue while the engine was ticking through the prayer → Fatal '
      '(real failure)', () async {
    await boot();
    heartbeatAt(t0); // engine alive since t0
    await _tick();
    overdueAt(t0.add(const Duration(seconds: 180))); // prayer was at t0+60
    await _tick();
    final incident = reporter.incidents.single;
    expect(incident.name, 'adhan_never_triggered');
    expect(incident.severity, ErrorSeverity.fatal);
    expect(incident.prayerKey, 'maghrib');
    expect(incident.evidence?['engine_alive'], isTrue);
  });

  test('overdue when the engine only woke AFTER the prayer → suppressed '
      '(natural: app was suspended/dead through the prayer)', () async {
    await boot();
    // The prayer fell at t0+60, but the engine's first heartbeat is at t0+200
    // (it was asleep and just woke) — a gap covering the prayer moment.
    heartbeatAt(t0.add(const Duration(seconds: 200)));
    await _tick();
    overdueAt(t0.add(const Duration(seconds: 210)));
    await _tick();
    expect(reporter.incidents, isEmpty);
  });

  test('overdue right after a time jump is suppressed (reset cleared '
      'adhansToday)', () async {
    await boot();
    // A clock jump (manual test / NTP sync / DST) clears the engine's
    // "already fired" set, so the overdue detector re-flags a fajr that DID
    // fire. The monitor must not raise a Fatal for it.
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'time_jump_detected',
      params: {'drift_seconds': 233},
    );
    await _tick();
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'prayer_overdue_no_trigger',
      params: {
        'prayer_key': 'fajr',
        'overdue_seconds': 293,
        'adhan_mode': 'sound',
      },
    );
    await _tick();
    expect(reporter.incidents, isEmpty);
  });

  test('overdue is suppressed when this prayer\'s adhan audio provably '
      'started (proof-based, independent of jump timing)', () async {
    await boot();
    // The adhan for fajr fired and its audio started — proof it sounded.
    _adhan(bus, 'FIRED', prayer: 'fajr');
    await _tick();
    _adhan(bus, 'AUDIO_STARTED', prayer: 'fajr');
    await _tick();
    // Much later, with NO recent time-jump grace, the overdue detector re-flags
    // fajr (e.g. adhansToday was cleared). Audio proof must dismiss it.
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'prayer_overdue_no_trigger',
      params: {
        'prayer_key': 'fajr',
        'overdue_seconds': 400,
        'adhan_mode': 'sound',
      },
    );
    await _tick();
    expect(reporter.incidents, isEmpty);
  });

  test('overdue for a DIFFERENT prayer than the one that sounded still '
      'reports (engine alive through it)', () async {
    await boot();
    heartbeatAt(t0); // engine alive since t0
    await _tick();
    _adhan(bus, 'AUDIO_STARTED', prayer: 'fajr'); // fajr sounded
    await _tick();
    // dhuhr never sounded and the engine was ticking through it → real.
    overdueAt(t0.add(const Duration(seconds: 180)), prayer: 'dhuhr');
    await _tick();
    expect(reporter.incidents.single.prayerKey, 'dhuhr');
  });

  test('time jump aborts an open tracker as expectedSkip', () async {
    await boot();
    _adhan(bus, 'FIRED');
    await _tick();
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'time_jump_detected',
      params: {'drift_seconds': 3600},
    );
    await _tick();
    expect(sink.runs.single.result, FlowResult.expectedSkip);
    expect(reporter.incidents, isEmpty);
  });

  test(
    'iqama funnel routed via prayer_alert_journey_state(alert_type=iqama)',
    () async {
      await boot();
      void iqama(String state) => bus.publish(
        source: TelemetrySource.analytics,
        name: 'prayer_alert_journey_state',
        params: {
          'alert_type': 'iqama',
          'prayer_key': 'dhuhr',
          'final_state': state,
        },
      );
      iqama('FIRED');
      await _tick();
      bus.publish(
        source: TelemetrySource.diag,
        name: 'alert_screen_rendered',
        params: {'flow': 'iqama', 'prayer_key': 'dhuhr'},
      );
      await _tick();
      iqama('AUDIO_STARTED');
      await _tick();
      iqama('AUDIO_COMPLETED');
      await _tick();
      expect(sink.runs.single.flow, 'iqama');
      expect(sink.runs.single.result, FlowResult.success);
    },
  );

  test('screen unconfirmed but audio provably started → success, no '
      'incident (proof-based suppression, foreground)', () async {
    await boot();
    _adhan(bus, 'FIRED');
    await _tick();
    // The adhan sound started (audio_start_succeeded) BEFORE any screen frame —
    // the call to prayer was heard. The screen takeover is unconfirmed, but the
    // core function provably worked, so this must NOT raise a false alarm.
    _adhan(bus, 'AUDIO_STARTED');
    await _tick();
    _adhan(bus, 'FAILED'); // screen step never arrived → fails at screen
    await _tick();
    expect(sink.runs.single.result, FlowResult.success);
    expect(sink.runs.single.reason, 'screen_unconfirmed_audio_ok');
    expect(reporter.incidents, isEmpty);
  });

  test(
    'screen AND sound both missing while foreground → real incident',
    () async {
      await boot();
      _adhan(bus, 'FIRED');
      await _tick();
      _adhan(bus, 'FAILED'); // neither screen nor audio ever started
      await _tick();
      expect(sink.runs.single.result, FlowResult.failure);
      final incident = reporter.incidents.single;
      expect(incident.failedStep, FlowStep.screenShown);
      // Evidence bundle lets the dashboard confirm "real" without breadcrumbs.
      expect(incident.evidence?['audio_started'], isFalse);
      expect(incident.evidence?['app_foreground'], isTrue);
    },
  );

  void completed(String prayer, int durationSeconds) => bus.publish(
    source: TelemetrySource.analytics,
    name: 'adhan_completed',
    params: {'prayer_key': prayer, 'duration_seconds': durationSeconds},
  );

  test('adhan whose real played length is far too short → truncated '
      'incident (blind spot #4)', () async {
    await boot();
    _adhan(bus, 'FIRED', prayer: 'maghrib');
    await _tick();
    _adhan(bus, 'AUDIO_STARTED', prayer: 'maghrib'); // records real audio start
    await _tick();
    completed('maghrib', 3); // engine says it only played 3s
    await _tick();
    final incident = reporter.incidents.singleWhere(
      (i) => i.name == 'adhan_audio_truncated',
    );
    expect(incident.severity, ErrorSeverity.error);
    expect(incident.secondsPlayed, 3);
  });

  test('a full-length adhan completion is NOT flagged as truncated', () async {
    await boot();
    _adhan(bus, 'FIRED', prayer: 'isha');
    await _tick();
    _adhan(bus, 'AUDIO_STARTED', prayer: 'isha');
    await _tick();
    completed('isha', 130); // a real, full adhan
    await _tick();
    expect(
      reporter.incidents.where((i) => i.name == 'adhan_audio_truncated'),
      isEmpty,
    );
  });

  test('a silent cycle (no audio start) with a short window is never '
      'flagged as truncated', () async {
    await boot();
    _adhan(bus, 'FIRED', prayer: 'fajr');
    await _tick();
    _adhan(bus, 'SILENT_VISUAL_ONLY', prayer: 'fajr'); // no AUDIO_STARTED
    await _tick();
    completed('fajr', 4);
    await _tick();
    expect(
      reporter.incidents.where((i) => i.name == 'adhan_audio_truncated'),
      isEmpty,
    );
  });

  test('iqama whose real played length is far too short → truncated '
      '(parity with adhan)', () async {
    await boot();
    void iqama(String state) => bus.publish(
      source: TelemetrySource.analytics,
      name: 'prayer_alert_journey_state',
      params: {
        'alert_type': 'iqama',
        'prayer_key': 'asr',
        'final_state': state,
      },
    );
    iqama('FIRED');
    await _tick();
    iqama('AUDIO_STARTED'); // records real iqama audio start
    await _tick();
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'iqama_completed',
      params: {'prayer_key': 'asr', 'duration_seconds': 2},
    );
    await _tick();
    final incident = reporter.incidents.singleWhere(
      (i) => i.name == 'iqama_audio_truncated',
    );
    expect(incident.flow, 'iqama');
    expect(incident.secondsPlayed, 2);
  });

  test('native audio stream error during an open adhan → run fails '
      '(blind spot #3)', () async {
    await boot();
    _adhan(bus, 'FIRED', prayer: 'dhuhr');
    await _tick();
    bus.publish(
      source: TelemetrySource.diag,
      name: 'alert_screen_rendered',
      params: {'flow': 'adhan', 'prayer_key': 'dhuhr'},
    );
    await _tick();
    _adhan(bus, 'AUDIO_STARTED', prayer: 'dhuhr');
    await _tick();
    // Screen shown + audio started, then the player dies asynchronously on its
    // event stream — the "started" sound never actually completed.
    bus.publish(
      source: TelemetrySource.diag,
      name: 'audio_event_stream_error',
      params: {'error_type': 'PlatformException'},
    );
    await _tick();
    expect(sink.runs.single.result, FlowResult.failure);
    expect(reporter.incidents.single.failedStep, FlowStep.audioCompleted);
  });

  test(
    'screen failure while backgrounded → expectedSkip, no incident',
    () async {
      await boot();
      bus.publish(
        source: TelemetrySource.analytics,
        name: 'app_lifecycle',
        params: {'state': 'paused'},
      );
      await _tick();
      _adhan(bus, 'FIRED');
      await _tick();
      _adhan(bus, 'FAILED'); // screen step fails while the app is backgrounded
      await _tick();
      expect(sink.runs.single.result, FlowResult.expectedSkip);
      expect(reporter.incidents, isEmpty);
    },
  );

  test('overdue carries the engine-computed cause into the incident '
      'evidence (the "exactly where" for the Control Room)', () async {
    await boot();
    heartbeatAt(t0); // engine alive since t0 → a real failure
    await _tick();
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'prayer_overdue_no_trigger',
      params: {
        'prayer_key': 'maghrib',
        'overdue_seconds': 120,
        'adhan_mode': 'sound',
        'cause': 'cycle_active_iqama_countdown',
      },
      at: t0.add(const Duration(seconds: 180)),
    );
    await _tick();
    final incident = reporter.incidents.single;
    expect(incident.name, 'adhan_never_triggered');
    expect(incident.evidence?['cause'], 'cycle_active_iqama_countdown');
  });

  test(
    'cycle_wedge_autohealed → warning incident naming the wedged phase',
    () async {
      await boot();
      bus.publish(
        source: TelemetrySource.diag,
        name: 'cycle_wedge_autohealed',
        params: {
          'wedged_phase': 'iqama_countdown',
          'wedged_prayer': 'maghrib',
          'over_sec': 640,
        },
      );
      await _tick();
      final incident = reporter.incidents.single;
      expect(incident.name, 'cycle_wedge_autohealed');
      expect(incident.severity, ErrorSeverity.warning);
      expect(incident.flow, 'iqama'); // iqama_countdown → iqama flow
      expect(incident.failedStep, 'iqama_countdown');
      expect(incident.prayerKey, 'maghrib');
    },
  );

  test(
    'adhan_trigger_threw → fatal incident carrying the error type',
    () async {
      await boot();
      bus.publish(
        source: TelemetrySource.diag,
        name: 'adhan_trigger_threw',
        params: {'trigger_prayer': 'fajr', 'error_type': 'StateError'},
      );
      await _tick();
      final incident = reporter.incidents.single;
      expect(incident.name, 'adhan_trigger_threw');
      expect(incident.severity, ErrorSeverity.fatal);
      expect(incident.prayerKey, 'fajr');
      expect(incident.evidence?['error_type'], 'StateError');
    },
  );
}
