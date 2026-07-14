import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/features/prayer/domain/prayer_time_calculator.dart'
    as calc;
import 'package:ghasaq/features/prayer/domain/entities/daily_prayer_times.dart';

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

    test('rescue catch-up covers short TV stalls after the live window', () {
      expect(calc.kAdhanRescueCatchUpSeconds, greaterThan(60));
      expect(calc.kAdhanRescueCatchUpSeconds, 300);
    });
  });

  group('markMissedPrayers respects the rescue window', () {
    final now = DateTime(2026, 7, 6, 12, 30, 0);
    // maghrib is only 40s past — INSIDE the 5-min rescue window; isha long past.
    List<PrayerEntry> prayersWith(Duration maghribAgo, Duration ishaAgo) => [
      PrayerEntry(key: 'maghrib', time: now.subtract(maghribAgo)),
      PrayerEntry(key: 'isha', time: now.subtract(ishaAgo)),
    ];

    test(
      'default 2s threshold marks anything a few seconds past (unchanged)',
      () {
        final r = calc.markMissedPrayers(
          prayersWith(const Duration(seconds: 3), const Duration(hours: 1)),
          now,
          const {},
          <String>{},
        );
        expect(r.newKeys, contains('maghrib_6'));
        expect(r.newKeys, contains('isha_6'));
      },
    );

    test('recovery threshold leaves a prayer still inside the rescue window', () {
      // The exact bug: a device stalled 40s past Maghrib tripped the time-jump
      // reload, which called recovery → old 2s rule pre-marked Maghrib missed →
      // the live rescue path was then blocked and the adhan never fired.
      final r = calc.markMissedPrayers(
        prayersWith(const Duration(seconds: 40), const Duration(hours: 1)),
        now,
        const {},
        <String>{},
        missedAfterSeconds: calc.kAdhanRescueCatchUpSeconds,
      );
      expect(
        r.newKeys,
        isNot(contains('maghrib_6')),
        reason: 'within rescue window → left for the live rescue to fire',
      );
      expect(
        r.newKeys,
        contains('isha_6'),
        reason: 'past the rescue window → genuinely missed',
      );
    });

    test('recovery threshold still marks a prayer past the rescue window', () {
      final r = calc.markMissedPrayers(
        prayersWith(
          const Duration(seconds: calc.kAdhanRescueCatchUpSeconds + 1),
          const Duration(hours: 1),
        ),
        now,
        const {},
        <String>{},
        missedAfterSeconds: calc.kAdhanRescueCatchUpSeconds,
      );
      expect(r.newKeys, contains('maghrib_6'));
    });
  });

  group('floorToSecond', () {
    test('drops milliseconds and microseconds', () {
      final t = DateTime(2026, 7, 4, 13, 45, 30, 450, 123);
      expect(calc.floorToSecond(t), DateTime(2026, 7, 4, 13, 45, 30));
    });

    test('leaves an already-whole second unchanged', () {
      final t = DateTime(2026, 7, 4, 13, 45, 30);
      expect(calc.floorToSecond(t), t);
    });

    test('always truncates down, never rounds up', () {
      final t = DateTime(2026, 7, 4, 13, 45, 30, 999);
      expect(calc.floorToSecond(t), DateTime(2026, 7, 4, 13, 45, 30));
    });

    test('whole-second target: countdown is phase-independent within a second', () {
      // The bug: iqamaDueAt = adhanTriggerTime + delay carried adhan's
      // sub-second fraction, so floor(dueAt - now) changed value at that random
      // fraction. When it drifted onto the 1 Hz tick's firing phase the shown
      // seconds stalled a tick then jumped 2, while the wall clock (boundary at
      // .000) stayed smooth. Flooring the target pins the countdown boundary to
      // .000 too: sampled at ANY sub-second phase inside one whole wall-second
      // it reads the SAME integer, so a jittery tick can never straddle it —
      // the countdown steps in lockstep with the clock.
      final adhanFired = DateTime(2026, 7, 4, 5, 12, 3, 450); // .450 fraction
      final dueAt = calc.floorToSecond(
        adhanFired.add(const Duration(minutes: 1)),
      ); // …:03.000
      final wallSecond = DateTime(2026, 7, 4, 5, 13, 1); // …:01.000
      final phases = [1, 137, 250, 500, 750, 999]
          .map(
            (ms) => dueAt
                .difference(wallSecond.add(Duration(milliseconds: ms)))
                .inSeconds,
          )
          .toSet();
      // A single value across all phases. The pre-fix fractional target would
      // yield two values here (the straddle that jumped the digits).
      expect(phases, {1});
    });
  });
}
