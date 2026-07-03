import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/quran/domain/entities/khatma_plan.dart';
import 'package:ghasaq/features/quran/domain/khatma_calculator.dart';

void main() {
  final created = DateTime(2026, 6, 19, 10);
  final start = DateTime(2026, 6, 19);

  group('createByDuration', () {
    test('30-day plan covers the whole Mushaf, target = start + 29 days', () {
      final k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      expect(k.startPage, 1);
      expect(k.endPage, 604);
      expect(k.totalPages, 604);
      expect(k.targetDate, DateTime(2026, 7, 18));
      expect(k.status, KhatmaStatus.active);
      expect(KhatmaCalculator.daysRemaining(k, start), 30);
    });

    test('day-only normalisation drops the time component', () {
      final k = KhatmaCalculator.createByDuration(
        startDate: DateTime(2026, 6, 19, 23, 59),
        durationDays: 10,
        createdAt: created,
      );
      expect(k.startDate, DateTime(2026, 6, 19));
    });

    test('duration is clamped to at least one day', () {
      final k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 0,
        createdAt: created,
      );
      expect(k.targetDate, start);
    });
  });

  group('createByDailyPages', () {
    test('20 pages/day over 604 pages needs 31 days', () {
      final k = KhatmaCalculator.createByDailyPages(
        startDate: start,
        pagesPerDay: 20,
        createdAt: created,
      );
      // ceil(604 / 20) = 31
      expect(KhatmaCalculator.daysRemaining(k, start), 31);
    });
  });

  group('todayTarget / todayRemaining (redistribution)', () {
    test('on-track 30-day plan asks for ~21 pages on day one', () {
      final k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      // ceil(604 / 30) = 21
      expect(KhatmaCalculator.todayTarget(k, start), 21);
      expect(KhatmaCalculator.todayRemaining(k, start), 21);
    });

    test('falling behind raises the remaining quota', () {
      // Day 1 of a 2-day, 10-page plan, nothing read, but already on the
      // final day → all 10 due today.
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 2,
        createdAt: created,
        endPage: 10,
      );
      final lastDay = start.add(const Duration(days: 1));
      expect(KhatmaCalculator.todayTarget(k, lastDay), 10);

      // After reading 4 pages on the last day, 6 remain due today.
      for (var p = 1; p <= 4; p++) {
        k = KhatmaCalculator.recordPage(k, p, lastDay);
      }
      expect(KhatmaCalculator.todayRemaining(k, lastDay), 6);
    });

    test('reading ahead shrinks the next day target', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 10,
        createdAt: created,
        endPage: 100,
      );
      // Read 50 pages on day one (target was ceil(100/10)=10).
      for (var p = 1; p <= 50; p++) {
        k = KhatmaCalculator.recordPage(k, p, start);
      }
      // Day 2: 50 pages left over 9 remaining days → ceil(50/9) = 6.
      final day2 = start.add(const Duration(days: 1));
      expect(KhatmaCalculator.todayTarget(k, day2), 6);
    });

    test('target stays stable as pages are read within the same day', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      final t0 = KhatmaCalculator.todayTarget(k, start);
      k = KhatmaCalculator.recordPage(k, 1, start);
      k = KhatmaCalculator.recordPage(k, 2, start);
      expect(KhatmaCalculator.todayTarget(k, start), t0);
      expect(KhatmaCalculator.todayRemaining(k, start), t0 - 2);
    });
  });

  group('recordPage', () {
    test('counts a new in-range page and bumps the daily log', () {
      final k0 = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      final k1 = KhatmaCalculator.recordPage(k0, 5, start);
      expect(k1.readCount, 1);
      expect(k1.dailyLog[khatmaDateKey(start)], 1);
    });

    test('re-reading a page is a no-op and returns the same instance', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      k = KhatmaCalculator.recordPage(k, 5, start);
      final again = KhatmaCalculator.recordPage(k, 5, start);
      expect(identical(again, k), isTrue);
      expect(again.readCount, 1);
    });

    test('out-of-range page is ignored', () {
      final k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
        startPage: 10,
        endPage: 20,
      );
      expect(identical(KhatmaCalculator.recordPage(k, 5, start), k), isTrue);
      expect(identical(KhatmaCalculator.recordPage(k, 99, start), k), isTrue);
    });

    test('flips to completed when the whole range is covered', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 5,
        createdAt: created,
        startPage: 1,
        endPage: 3,
      );
      k = KhatmaCalculator.recordPage(k, 1, start);
      k = KhatmaCalculator.recordPage(k, 2, start);
      expect(k.isCompleted, isFalse);
      k = KhatmaCalculator.recordPage(k, 3, start);
      expect(k.isCompleted, isTrue);
      expect(k.status, KhatmaStatus.completed);
      expect(KhatmaCalculator.todayTarget(k, start), 0);
    });
  });

  group('nextUnreadPage', () {
    test('returns the smallest unread page in the range', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
        startPage: 10,
        endPage: 20,
      );
      expect(KhatmaCalculator.nextUnreadPage(k), 10);
      k = KhatmaCalculator.recordPage(k, 10, start);
      k = KhatmaCalculator.recordPage(k, 11, start);
      expect(KhatmaCalculator.nextUnreadPage(k), 12);
    });

    test('returns null once the range is complete', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
        startPage: 1,
        endPage: 2,
      );
      k = KhatmaCalculator.recordPage(k, 1, start);
      k = KhatmaCalculator.recordPage(k, 2, start);
      expect(KhatmaCalculator.nextUnreadPage(k), isNull);
    });
  });

  group('currentStreak', () {
    test('counts consecutive reading days ending today', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      final d1 = start;
      final d2 = start.add(const Duration(days: 1));
      final d3 = start.add(const Duration(days: 2));
      k = KhatmaCalculator.recordPage(k, 1, d1);
      k = KhatmaCalculator.recordPage(k, 2, d2);
      k = KhatmaCalculator.recordPage(k, 3, d3);
      expect(KhatmaCalculator.currentStreak(k, d3), 3);
    });

    test('grace: today unread but yesterday read keeps the streak', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      final yesterday = start;
      final today = start.add(const Duration(days: 1));
      k = KhatmaCalculator.recordPage(k, 1, yesterday);
      expect(KhatmaCalculator.currentStreak(k, today), 1);
    });

    test('a skipped day breaks the streak', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      k = KhatmaCalculator.recordPage(k, 1, start);
      // Two days later with no reading in between, and today unread.
      final twoDaysLater = start.add(const Duration(days: 2));
      expect(KhatmaCalculator.currentStreak(k, twoDaysLater), 0);
    });
  });

  group('todayWird', () {
    test('day one of a 30-day plan is pages 1..21', () {
      final k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      final w = KhatmaCalculator.todayWird(k, start);
      expect(w, isNotNull);
      expect(w!.first, 1);
      expect(w.last, 21); // ceil(604/30) = 21 pages
    });

    test('advances to the next contiguous block after completion', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      final w1 = KhatmaCalculator.todayWird(k, start)!;
      for (var p = w1.first; p <= w1.last; p++) {
        k = KhatmaCalculator.recordPage(k, p, start);
      }
      final w2 = KhatmaCalculator.todayWird(k, start)!;
      expect(w2.first, w1.last + 1);
    });

    test('clamps the last page to the plan end', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 2,
        createdAt: created,
        endPage: 5,
      );
      // Read 3, leaving pages 4..5; on the final day the wird is just 4..5.
      for (var p = 1; p <= 3; p++) {
        k = KhatmaCalculator.recordPage(k, p, start);
      }
      final lastDay = start.add(const Duration(days: 1));
      final w = KhatmaCalculator.todayWird(k, lastDay)!;
      expect(w.first, 4);
      expect(w.last, 5);
    });

    test('returns null once complete', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
        endPage: 2,
      );
      k = KhatmaCalculator.recordPage(k, 1, start);
      k = KhatmaCalculator.recordPage(k, 2, start);
      expect(KhatmaCalculator.todayWird(k, start), isNull);
    });
  });

  group('JSON round-trip', () {
    test('survives encode/decode with progress', () {
      var k = KhatmaCalculator.createByDuration(
        startDate: start,
        durationDays: 30,
        createdAt: created,
      );
      k = KhatmaCalculator.recordPage(k, 1, start);
      k = KhatmaCalculator.recordPage(k, 2, start);
      final restored = Khatma.fromJson(k.toJson());
      expect(restored, isNotNull);
      expect(restored!.readPages, k.readPages);
      expect(restored.dailyLog, k.dailyLog);
      expect(restored.targetDate, k.targetDate);
      expect(restored.status, k.status);
    });

    test('returns null on malformed payload', () {
      expect(Khatma.fromJson({'startPage': 'oops'}), isNull);
    });
  });
}
