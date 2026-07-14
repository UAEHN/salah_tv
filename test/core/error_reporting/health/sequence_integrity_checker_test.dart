import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/domain/error_severity.dart';
import 'package:ghasaq/core/error_reporting/health/health_state_store.dart';
import 'package:ghasaq/core/error_reporting/health/sequence_integrity_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_error_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeErrorReporter reporter;
  late DateTime now;

  SequenceIntegrityChecker build({String sessionId = 's1'}) =>
      SequenceIntegrityChecker(
        reporter: reporter,
        store: HealthStateStore(),
        sessionId: sessionId,
        clock: () => now,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    reporter = FakeErrorReporter();
    now = DateTime(2026, 7, 3, 12);
  });

  test('correct successor → no violation', () async {
    final checker = build();
    await checker.initialize();
    await checker.onPrayerFired('fajr');
    await checker.onPrayerFired('dhuhr');
    await checker.onPrayerFired('asr');
    expect(reporter.incidents, isEmpty);
  });

  test('skipped prayer → Fatal violation with expected/actual', () async {
    final checker = build();
    await checker.initialize();
    await checker.onPrayerFired('asr');
    await checker.onPrayerFired('fajr'); // should have been maghrib
    expect(reporter.incidents, hasLength(1));
    final incident = reporter.incidents.single;
    expect(incident.severity, ErrorSeverity.fatal);
    expect(incident.expected, 'maghrib');
    expect(incident.actual, 'fajr');
    expect(incident.flow, 'sequence');
  });

  test('isha → fajr across the day boundary is valid', () async {
    final checker = build();
    await checker.initialize();
    await checker.onPrayerFired('isha');
    now = DateTime(2026, 7, 4, 4); // next day, Fajr
    await checker.onPrayerFired('fajr');
    expect(reporter.incidents, isEmpty);
  });

  test(
    'restart (new session) re-anchors — first fire never violates',
    () async {
      final first = build(sessionId: 's1');
      await first.initialize();
      await first.onPrayerFired('asr'); // persisted

      // Simulate relaunch: markMissedPrayers suppressed fajr..asr, isha fires.
      final second = build(sessionId: 's2');
      await second.initialize();
      await second.onPrayerFired('isha');
      expect(reporter.incidents, isEmpty);
    },
  );

  test(
    'reanchor() clears the anchor so the next fire never violates',
    () async {
      final checker = build();
      await checker.initialize();
      await checker.onPrayerFired('asr');
      await checker.reanchor(); // city change / time jump
      await checker.onPrayerFired('fajr'); // would be a skip without reanchor
      expect(reporter.incidents, isEmpty);
    },
  );

  test('sunrise is never treated as a sequence step', () async {
    final checker = build();
    await checker.initialize();
    await checker.onPrayerFired('fajr');
    await checker.onPrayerFired('sunrise'); // ignored
    await checker.onPrayerFired('dhuhr'); // still the valid successor of fajr
    expect(reporter.incidents, isEmpty);
  });
}
