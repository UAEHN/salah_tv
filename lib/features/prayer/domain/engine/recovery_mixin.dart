import '../entities/daily_prayer_times.dart';
import '../prayer_time_calculator.dart' as calc;
import 'prayer_cycle_base.dart';

/// Handles iqama recovery when the app resumes after missing a prayer trigger.
/// Issue 8: marks all missed prayers to prevent duplicate adhan fires.
mixin RecoveryMixin on PrayerCycleBase {
  /// Checks if we are in the iqama-countdown window for a prayer whose
  /// adhan trigger was missed (app was killed or suspended at prayer time).
  /// If so, starts the countdown with the remaining seconds.
  void recoverIqamaState() {
    if (s.todayPrayers == null) return;
    // Do not interfere if a cycle is already in progress
    if (s.isCycleActive) return;

    final missed = markMissedPrayers();
    if (missed == null) return;

    final iqamaDelayMin = settings.iqamaDelays[missed.key] ?? 0;
    if (iqamaDelayMin <= 0) return;

    // Iqama target = adjusted prayer time + iqama delay
    final iqamaAt = calc
        .adjustedPrayerTime(missed, settings.adhanOffsets)
        .add(Duration(minutes: iqamaDelayMin));
    final remaining = iqamaAt.difference(s.now);

    if (remaining.inSeconds > 0) {
      // Still inside the iqama countdown window — show it
      s.isIqamaCountdown = true;
      s.iqamaCountdown = remaining;
      s.iqamaPrayerName = missed.name;
      s.currentAdhanPrayerName = missed.name;
      s.activeCyclePrayerKey = missed.key; // lock card highlight on recovery
    }
    // If remaining <= 0 the iqama window has already closed — nothing to show
  }

  /// Issue 8: mark ALL missed prayers in adhansToday so checkAdhanTrigger
  /// never re-fires any of them. Returns the latest missed prayer, or null.
  PrayerEntry? markMissedPrayers() {
    final result = calc.markMissedPrayers(
      s.todayPrayers!.prayersOnly,
      s.now,
      settings.adhanOffsets,
      s.adhansToday,
    );
    s.adhansToday.addAll(result.newKeys);
    return result.missed;
  }
}
