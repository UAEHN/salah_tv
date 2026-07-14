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

/// Drops the sub-second part of [t] so it lands exactly on a whole second.
///
/// Every countdown target in the app is whole-second-aligned (prayer times are
/// whole minutes) EXCEPT the iqama target, which is anchored to the arbitrary
/// sub-second instant the adhan fired. A countdown shown as `floor(target -
/// now)` changes value at the target's sub-second fraction; when that fraction
/// drifts near the 1 Hz tick's firing phase, each tick samples right on the
/// boundary and the displayed seconds stall a tick then jump by 2 — while the
/// wall clock (boundary at .000) stays smooth. Flooring the iqama target to a
/// whole second puts its boundary back on .000 so the countdown steps in
/// lockstep with the clock's own smooth cadence.
DateTime floorToSecond(DateTime t) =>
    DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);

/// How many seconds *after* a prayer's adjusted time the live trigger may
/// still fire. The 1 Hz tick can stall for several seconds on slow TV boxes
/// (GC, video decode, brief system overlays), so a window of only 1–2s could
/// be skipped over entirely — the adhan would then never fire for that prayer.
/// This catch-up window lets a late tick still play the adhan. Kept below the
/// 60s overdue threshold so a genuinely missed prayer still surfaces as
/// `prayer_overdue_no_trigger` instead of firing a clearly-stale adhan.
const int kAdhanCatchUpSeconds = 30;

/// TV safety net: if the 1 Hz timer or Flutter isolate stalls past the normal
/// live window, still fire the adhan shortly after the prayer instead of
/// silently skipping the whole visual/audio takeover.
const int kAdhanRescueCatchUpSeconds = 5 * 60;

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
/// A prayer is "missed" if its adjusted time has passed by more than
/// [missedAfterSeconds] and it has not yet been recorded in [adhansToday].
///
/// [missedAfterSeconds] defaults to 2 (the historical "any time past" rule) but
/// recovery passes [kAdhanRescueCatchUpSeconds]: a prayer still inside the live
/// rescue window must NOT be pre-marked as missed here, or it would block
/// [isWithinAdhanFireWindow]'s rescue path from firing its adhan — the exact
/// case where a device that slept a few seconds past the prayer lost its adhan.
({PrayerEntry? missed, List<String> newKeys}) markMissedPrayers(
  List<PrayerEntry> prayers,
  DateTime now,
  Map<String, int> adhanOffsets,
  Set<String> adhansToday, {
  int missedAfterSeconds = 2,
}) {
  PrayerEntry? missed;
  final newKeys = <String>[];

  for (final p in prayers) {
    final key = '${p.key}_${now.day}';
    if (adhansToday.contains(key)) continue;
    final timeSince = now.difference(adjustedPrayerTime(p, adhanOffsets));
    if (timeSince.inSeconds > missedAfterSeconds) {
      newKeys.add(key);
      missed = p; // keep overwriting — ends up as the latest one
    }
  }
  return (missed: missed, newKeys: newKeys);
}
