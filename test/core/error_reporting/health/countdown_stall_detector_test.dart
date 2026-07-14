import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/domain/error_severity.dart';
import 'package:ghasaq/core/error_reporting/health/countdown_stall_detector.dart';

import 'fake_error_reporter.dart';

void main() {
  test('does not arm before the first heartbeat', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      CountdownStallDetector(reporter: reporter);
      async.elapse(const Duration(minutes: 10));
      expect(reporter.incidents, isEmpty);
    });
  });

  test('stall fires after the window with no heartbeat', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      final detector = CountdownStallDetector(reporter: reporter);
      detector.onHeartbeat(nextPrayerKey: 'asr');
      async.elapse(const Duration(seconds: 151));
      expect(reporter.incidents, hasLength(1));
      final incident = reporter.incidents.single;
      expect(incident.flow, 'countdown');
      expect(incident.prayerKey, 'asr');
      expect(incident.severity, ErrorSeverity.error);
      detector.dispose();
    });
  });

  test('a heartbeat within the window resets the watchdog', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      final detector = CountdownStallDetector(reporter: reporter);
      detector.onHeartbeat(nextPrayerKey: 'asr');
      async.elapse(const Duration(seconds: 100));
      detector.onHeartbeat(nextPrayerKey: 'asr'); // reset
      async.elapse(const Duration(seconds: 100));
      expect(reporter.incidents, isEmpty);
      detector.dispose();
    });
  });

  test('re-arms after a stall (persistent freeze reported again)', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      final detector = CountdownStallDetector(reporter: reporter);
      detector.onHeartbeat(nextPrayerKey: 'asr');
      async.elapse(const Duration(seconds: 151));
      async.elapse(const Duration(seconds: 151));
      expect(reporter.incidents, hasLength(2));
      detector.dispose();
    });
  });

  test('stall evidence carries the real freeze duration (frozen_ms)', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      final detector = CountdownStallDetector(reporter: reporter);
      detector.onHeartbeat(nextPrayerKey: 'asr');
      async.elapse(const Duration(seconds: 151));
      final evidence = reporter.incidents.single.evidence;
      expect(evidence, isNotNull);
      expect(evidence!.containsKey('frozen_ms'), isTrue);
      detector.dispose();
    });
  });

  test('backgrounded app disarms the watchdog', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      final detector = CountdownStallDetector(reporter: reporter);
      detector.onHeartbeat(nextPrayerKey: 'asr');
      detector.onLifecycle('paused');
      async.elapse(const Duration(minutes: 10));
      expect(reporter.incidents, isEmpty);
      detector.dispose();
    });
  });

  test('empty next-prayer heartbeat disarms (onboarding / no live clock)', () {
    fakeAsync((async) {
      final reporter = FakeErrorReporter();
      final detector = CountdownStallDetector(reporter: reporter);
      detector.onHeartbeat(nextPrayerKey: 'asr'); // arm on a live clock
      detector.onHeartbeat(nextPrayerKey: ''); // no schedule → disarm
      async.elapse(const Duration(minutes: 10));
      expect(reporter.incidents, isEmpty);
      detector.dispose();
    });
  });
}
