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
