import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/features/prayer/domain/prayer_time_calculator.dart'
    as calc;

void main() {
  group('isWithinAdhanFireWindow', () {
    test('fires exactly at prayer time (diff 0)', () {
      expect(calc.isWithinAdhanFireWindow(0), isTrue);
    });

    test('does NOT fire before prayer time (negative diff)', () {
      expect(calc.isWithinAdhanFireWindow(-1), isFalse);
    });

    test('still fires inside the old 2s window', () {
      expect(calc.isWithinAdhanFireWindow(2), isTrue);
    });

    test('fires for a stalled tick that lands a few seconds late', () {
      // The exact case that used to silently skip the adhan on slow boxes.
      expect(calc.isWithinAdhanFireWindow(5), isTrue);
      expect(calc.isWithinAdhanFireWindow(20), isTrue);
    });

    test('fires up to and including the catch-up boundary', () {
      expect(calc.isWithinAdhanFireWindow(calc.kAdhanCatchUpSeconds), isTrue);
    });

    test('does NOT fire once past the catch-up boundary', () {
      expect(
        calc.isWithinAdhanFireWindow(calc.kAdhanCatchUpSeconds + 1),
        isFalse,
      );
    });

    test('catch-up stays below the 60s overdue threshold', () {
      // Guarantees a genuinely missed prayer surfaces as overdue telemetry
      // rather than firing a clearly-stale adhan.
      expect(calc.kAdhanCatchUpSeconds, lessThan(60));
    });
  });
}
