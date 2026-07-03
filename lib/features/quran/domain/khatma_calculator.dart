import 'dart:math' as math;

import 'entities/khatma_plan.dart';

/// 'yyyy-MM-dd' key for a local calendar day. The day boundary is local
/// midnight — the convention used by mainstream Quran reading-goal features
/// (Quran.com resets the daily goal "based on local timezone").
String khatmaDateKey(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A contiguous run of pages to read in one sitting (today's portion).
typedef KhatmaWird = ({int first, int last});

/// Pure derivations for a [Khatma]. No I/O, no plugins — domain-safe and
/// unit-tested in isolation. All date math uses the local calendar day.
class KhatmaCalculator {
  const KhatmaCalculator._();

  /// Builds a plan that finishes [startPage]..[endPage] across [durationDays]
  /// (inclusive of the start day), splitting the range equally per day.
  static Khatma createByDuration({
    required DateTime startDate,
    required int durationDays,
    required DateTime createdAt,
    int startPage = 1,
    int endPage = 604,
  }) {
    final days = math.max(1, durationDays);
    final start = _dateOnly(startDate);
    return Khatma(
      startPage: startPage,
      endPage: endPage,
      startDate: start,
      targetDate: start.add(Duration(days: days - 1)),
      createdAt: createdAt,
    );
  }

  /// Builds a plan sized by a fixed [pagesPerDay] quota; the target date is
  /// derived from the range size.
  static Khatma createByDailyPages({
    required DateTime startDate,
    required int pagesPerDay,
    required DateTime createdAt,
    int startPage = 1,
    int endPage = 604,
  }) {
    final total = endPage - startPage + 1;
    final perDay = math.max(1, pagesPerDay);
    return createByDuration(
      startDate: startDate,
      durationDays: (total / perDay).ceil(),
      createdAt: createdAt,
      startPage: startPage,
      endPage: endPage,
    );
  }

  /// Marks [page] as read on [today]. Only in-range pages not already counted
  /// advance the Khatma (re-reads return the same instance unchanged), and the
  /// day's new-page tally is bumped for the streak/heatmap. Flips the status
  /// to completed once the whole range is covered.
  static Khatma recordPage(Khatma k, int page, DateTime today) {
    if (page < k.startPage || page > k.endPage) return k;
    if (k.readPages.contains(page)) return k;
    final pages = {...k.readPages, page};
    final key = khatmaDateKey(today);
    final log = {...k.dailyLog, key: (k.dailyLog[key] ?? 0) + 1};
    return k.copyWith(
      readPages: pages,
      dailyLog: log,
      status: pages.length >= k.totalPages
          ? KhatmaStatus.completed
          : KhatmaStatus.active,
    );
  }

  static int remainingPages(Khatma k) => k.totalPages - k.readCount;

  static double progressFraction(Khatma k) =>
      k.totalPages == 0 ? 0 : k.readCount / k.totalPages;

  /// Days from [today] to the target date, inclusive of today. Never below 1:
  /// on or after the target the whole remainder is due now.
  static int daysRemaining(Khatma k, DateTime today) {
    final diff = _dateOnly(k.targetDate).difference(_dateOnly(today)).inDays;
    return math.max(1, diff + 1);
  }

  /// Today's full page target (read + still-to-read), after redistribution.
  /// Based on the range left at the start of today spread over the days left,
  /// so it stays stable as the user reads through the day.
  static int todayTarget(Khatma k, DateTime today) {
    if (k.isCompleted) return 0;
    final doneToday = k.dailyLog[khatmaDateKey(today)] ?? 0;
    final remainingBeforeToday = remainingPages(k) + doneToday;
    return (remainingBeforeToday / daysRemaining(k, today)).ceil();
  }

  /// Pages the user should still read today to stay on track.
  static int todayRemaining(Khatma k, DateTime today) {
    final doneToday = k.dailyLog[khatmaDateKey(today)] ?? 0;
    return math.max(0, todayTarget(k, today) - doneToday);
  }

  /// Smallest unread page in the range — where the reader should open for the
  /// next portion. Null when the Khatma is complete.
  static int? nextUnreadPage(Khatma k) {
    for (var p = k.startPage; p <= k.endPage; p++) {
      if (!k.readPages.contains(p)) return p;
    }
    return null;
  }

  /// Today's wird: the next [todayTarget] unread pages as one contiguous run
  /// starting at the first unread page. Null when the Khatma is complete.
  /// Reading is sequential, so the unread pages form a single tail block.
  static KhatmaWird? todayWird(Khatma k, DateTime today) {
    final first = nextUnreadPage(k);
    if (first == null) return null;
    final size = todayTarget(k, today);
    final last = (first + size - 1).clamp(first, k.endPage);
    return (first: first, last: last);
  }

  /// Consecutive days (ending today) with at least one new page read. If today
  /// has no reading yet, yesterday's streak still counts — grace until local
  /// midnight, matching the "read ≥1 a day" convention.
  static int currentStreak(Khatma k, DateTime today) {
    var cursor = _dateOnly(today);
    if ((k.dailyLog[khatmaDateKey(cursor)] ?? 0) == 0) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while ((k.dailyLog[khatmaDateKey(cursor)] ?? 0) > 0) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
