import 'entities/daily_prayer_times.dart';

/// Pure utility functions for prayer time calculations.
/// No state, no side-effects — fully unit-testable.

/// Formats [d] as 'dd/MM/yyyy' without requiring the intl package.
String dateKey(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Returns the offset-adjusted time for [p] using [adhanOffsets].
DateTime adjustedPrayerTime(PrayerEntry p, Map<String, int> adhanOffsets) {
  final offsetMin = adhanOffsets[p.key] ?? 0;
  return p.time.add(Duration(minutes: offsetMin));
}

/// How many seconds *after* a prayer's adjusted time the live trigger may
/// still fire. The 1 Hz tick can stall for several seconds on slow TV boxes
/// (GC, video decode, brief system overlays), so a window of only 1–2s could
/// be skipped over entirely — the adhan would then never fire for that prayer.
/// This catch-up window lets a late tick still play the adhan. Kept below the
/// 60s overdue threshold so a genuinely missed prayer still surfaces as
/// `prayer_overdue_no_trigger` instead of firing a clearly-stale adhan.
const int kAdhanCatchUpSeconds = 30;

/// True when [diffSeconds] (now − adjusted prayer time) is inside the live
/// adhan fire window: at or after the prayer time, and no later than
/// [kAdhanCatchUpSeconds]. Pure so the trigger boundary is unit-testable
/// without spinning up the engine.
bool isWithinAdhanFireWindow(int diffSeconds) =>
    diffSeconds >= 0 && diffSeconds <= kAdhanCatchUpSeconds;

/// Finds the next upcoming prayer and its countdown from [now].
/// Returns `(next: null, countdown: zero)` when all prayers have passed.
({PrayerEntry? next, Duration countdown}) findNextPrayer(
  List<PrayerEntry> prayers,
  DateTime now,
  Map<String, int> adhanOffsets,
) {
  PrayerEntry? next;
  Duration shortest = const Duration(days: 1);

  for (final p in prayers) {
    final diff = adjustedPrayerTime(p, adhanOffsets).difference(now);
    if (diff.isNegative) continue;
    if (diff < shortest) {
      shortest = diff;
      next = p;
    }
  }
  return (next: next, countdown: next != null ? shortest : Duration.zero);
}

/// Marks all missed prayers in [adhansToday] and returns the latest missed
/// prayer plus the newly-added set keys.
///
/// A prayer is "missed" if its adjusted time has passed by more than 2 seconds
/// and it has not yet been recorded in [adhansToday].
({PrayerEntry? missed, List<String> newKeys}) markMissedPrayers(
  List<PrayerEntry> prayers,
  DateTime now,
  Map<String, int> adhanOffsets,
  Set<String> adhansToday,
) {
  PrayerEntry? missed;
  final newKeys = <String>[];

  for (final p in prayers) {
    final key = '${p.key}_${now.day}';
    if (adhansToday.contains(key)) continue;
    final timeSince = now.difference(adjustedPrayerTime(p, adhanOffsets));
    if (timeSince.inSeconds > 2) {
      newKeys.add(key);
      missed = p; // keep overwriting — ends up as the latest one
    }
  }
  return (missed: missed, newKeys: newKeys);
}
