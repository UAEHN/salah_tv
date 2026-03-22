import 'dart:async';

import '../prayer_time_calculator.dart' as calc;
import 'prayer_cycle_base.dart';
import 'adhan_cycle_mixin.dart';
import 'iqama_mixin.dart';
import 'recovery_mixin.dart';

/// Manages the 1-second tick, date-change detection, next-prayer calculation,
/// and pre-alert/announcement checks.
/// Issue comments 6 and 11 are preserved verbatim.
mixin TickMixin on PrayerCycleBase, AdhanCycleMixin, IqamaMixin, RecoveryMixin {
  void tick(Timer t) {
    final prev = s.now;
    s.now = DateTime.now();

    // Detect system time change: if the clock jumped by more than 5 seconds
    // (forward or backward), treat it as a manual time adjustment and reload.
    final drift = s.now.difference(prev).inSeconds;
    if (drift.abs() > 5) {
      s.adhansToday.clear();
      loadToday();
      recoverIqamaState();
      notify();
      return;
    }

    // Issue 6: date-change detection — replaces the fragile == 00:00:00 check
    // that could be skipped when Timer.periodic drifts on slow hardware.
    if (s.now.day != s.lastLoadedDay) {
      s.adhansToday.clear();
      s.preAlertBellPlayed.clear();
      s.preAnnouncementPlayed.clear();
      loadToday();
    }

    // Retry if prayer data was temporarily null while async cache was rebuilding
    // (e.g. after setActiveCity triggers _refreshCache in the background).
    if (s.todayPrayers == null) loadToday();
    if (s.needsIqamaRecovery && s.todayPrayers != null) {
      recoverIqamaState();
      s.needsIqamaRecovery = false;
    }

    updateNextPrayer();
    checkPreAnnouncement();
    checkPreAlertBell();
    checkAdhanTrigger();
    tickIqama();
    notify();
  }

  void loadToday() {
    // Hot path (1 Hz tick) — sync O(1) cache read; Either overhead not justified.
    s.todayPrayers = repo.getToday();
    s.lastLoadedDay = s.now.day; // Issue 6: record the day we loaded for
    updateNextPrayer();
    if (s.todayPrayers != null) {
      unawaited(notifications?.scheduleForDay(s.todayPrayers!, settings));
    }
  }

  void updateNextPrayer() {
    if (s.todayPrayers == null) return;
    final (:next, :countdown) = calc.findNextPrayer(
      s.todayPrayers!.prayersOnly,
      s.now,
      settings.adhanOffsets,
    );

    if (next != null) {
      s.nextPrayerName = next.name;
      s.nextPrayerKey = next.key;
      s.countdown = countdown;
    } else {
      // All prayers done today — countdown to tomorrow's Fajr
      s.nextPrayerName = 'الفجر';
      s.nextPrayerKey = 'fajr';
      final tomorrow = DateTime(s.now.year, s.now.month, s.now.day + 1);
      final tomorrowKey = calc.dateKey(tomorrow);
      // Hot path — sync O(1) cache read.
      final tomorrowPrayers = repo.getTomorrowByKey(tomorrowKey);
      if (tomorrowPrayers != null) {
        final fajrOffset = settings.adhanOffsets['fajr'] ?? 0;
        final adjustedFajr = tomorrowPrayers.fajr.add(
          Duration(minutes: fajrOffset),
        );
        final diff = adjustedFajr.difference(s.now);
        s.countdown = diff.isNegative ? Duration.zero : diff;
      } else {
        s.countdown = Duration.zero;
      }
    }
  }

  /// Play the prayer-name announcement 5 seconds before adhan fires.
  void checkPreAnnouncement() {
    if (s.isCycleActive) return;
    final key = '${s.nextPrayerKey}_${s.now.day}';
    if (s.preAnnouncementPlayed.contains(key)) return;
    if (s.countdown.inSeconds > 0 && s.countdown.inSeconds <= 5) {
      s.preAnnouncementPlayed.add(key);
      unawaited(audio.playPrayerAnnouncement(s.nextPrayerKey));
    }
  }

  /// Play a soft bell once when the countdown enters the 1-minute pre-alert window.
  void checkPreAlertBell() {
    if (!s.isPrePrayerAlert) return;
    final key = '${s.nextPrayerKey}_${s.now.day}';
    if (s.preAlertBellPlayed.contains(key)) return;
    s.preAlertBellPlayed.add(key);
    audio.playPreAlertBell();
  }
}
