import 'dart:async';

import '../prayer_time_calculator.dart' as calc;
import 'prayer_cycle_base.dart';
import 'adhan_cycle_mixin.dart';
import 'iqama_mixin.dart';
import 'recovery_mixin.dart';
import 'tick_diagnostics.dart';

/// Display window for the after-prayer adhkar takeover before Quran resumes.
const Duration _kAfterPrayerAdhkarWindow = Duration(minutes: 5);

/// Safety cap for the morning/evening session adhkar takeover. It normally ends
/// when its audio playlist finishes (via [stopSessionAdhkar], relayed from the
/// screen); this window only forces Quran back if that completion never fires.
/// Scheduling (iqama end + 25 min) lives in [IqamaMixin.stopIqama].
const Duration _kSessionAdhkarWindow = Duration(minutes: 30);

/// Tick-to-tick drift above this is treated as a real clock change (manual
/// adjustment / timezone / DST) and triggers a reload. Set well above any
/// plausible 1 Hz tick stall on slow TV boxes (a few seconds of GC / decode):
/// a 5s threshold misread such stalls as time jumps and reset the cycle,
/// marking the due prayer as missed so its adhan never fired. Real clock
/// changes are minutes/hours, so 30s keeps detection intact.
const int _kTimeJumpThresholdSeconds = 30;

/// Manages the 1-second tick, date-change detection, next-prayer calculation,
/// and pre-alert/announcement checks.
/// Issue comments 6 and 11 are preserved verbatim.
mixin TickMixin on PrayerCycleBase, AdhanCycleMixin, IqamaMixin, RecoveryMixin {
  void tick(Timer t) {
    final prev = s.now;
    s.now = currentTime();

    // Detect system time change: a tick-to-tick jump beyond the threshold
    // (forward or backward) is treated as a manual time adjustment and reloads.
    final drift = s.now.difference(prev).inSeconds;
    if (drift.abs() > _kTimeJumpThresholdSeconds) {
      analytics?.logTimeJumpDetected(driftSeconds: drift);
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
      // Phase 1C.1: dedup sets are scoped per day. Reset them with
      // adhansToday so today's overdue/skipped events can fire fresh.
      s.overdueReported.clear();
      s.skippedReported.clear();
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

    // Close the mosque-mode post-iqama prayer window once 10 minutes elapse.
    final until = s.prayerInProgressEndsAt;
    if (until != null && !s.now.isBefore(until)) {
      s.prayerInProgressEndsAt = null;
    }

    checkAfterPrayerAdhkar();
    checkSessionAdhkar();
    updateNextPrayer();
    checkPreAnnouncement();
    checkPreAlertBell();
    checkAdhanTrigger();
    tickIqama();
    runTickDiagnostics(); // Phase 1C — see tick_diagnostics.dart
    notify();
  }

  void loadToday() {
    // Hot path (1 Hz tick) — sync O(1) cache read; Either overhead not justified.
    s.todayPrayers = repo.getToday();
    s.lastLoadedDay = s.now.day; // Issue 6: record the day we loaded for
    updateNextPrayer();
    if (s.todayPrayers != null) {
      // Schedule today + tomorrow so notifications survive overnight app
      // closures and device reboots (boot receiver re-registers persisted
      // alarms; tomorrow's times remain in the future after a midnight restart).
      final tomorrowKey = calc.dateKey(
        DateTime(s.now.year, s.now.month, s.now.day + 1),
      );
      final tomorrow = repo.getTomorrowByKey(tomorrowKey);
      unawaited(
        notifications?.scheduleForDay(s.todayPrayers!, tomorrow, settings),
      );
      // Adhkar reminders are scheduled 7 days ahead so they keep firing even
      // if the phone has been off or the app has not been opened for days.
      // Independent of prayer times — the user picks the wall-clock time.
      unawaited(notifications?.scheduleAdhkar(settings));
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
      s.nextPrayerKey = next.key;
      s.countdown = countdown;
    } else {
      // All prayers done today — countdown to tomorrow's Fajr
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
  /// Mosque mode: muezzin handles the call live — never play the cue.
  void checkPreAnnouncement() {
    if (settings.isMosqueMode) return;
    if (s.isCycleActive) return;
    final key = '${s.nextPrayerKey}_${s.now.day}';
    if (s.preAnnouncementPlayed.contains(key)) return;
    if (s.countdown.inSeconds > 0 && s.countdown.inSeconds <= 5) {
      s.preAnnouncementPlayed.add(key);
      unawaited(audio.playPrayerAnnouncement(s.nextPrayerKey));
    }
  }

  /// Play a soft bell once when the countdown enters the 1-minute pre-alert window.
  /// Mosque mode: muezzin handles the call live — never play the cue.
  void checkPreAlertBell() {
    if (settings.isMosqueMode) return;
    if (!s.isPrePrayerAlert) return;
    final key = '${s.nextPrayerKey}_${s.now.day}';
    if (s.preAlertBellPlayed.contains(key)) return;
    s.preAlertBellPlayed.add(key);
    audio.playPreAlertBell();
  }

  /// Drives the after-prayer adhkar takeover scheduled by [stopIqama]: starts
  /// it (pausing Quran) when its time arrives, and ends it (resuming Quran)
  /// after the display window. pauseQuranForAdhan/resumeQuranAfterAdhan reach
  /// here transitively through AdhanCycleMixin → QuranMixin.
  void checkAfterPrayerAdhkar() {
    final startAt = s.afterPrayerAdhkarStartsAt;
    if (startAt != null &&
        !s.now.isBefore(startAt) &&
        !s.isAfterPrayerAdhkarPlaying) {
      s.afterPrayerAdhkarStartsAt = null;
      s.isAfterPrayerAdhkarPlaying = true;
      s.afterPrayerAdhkarEndsAt = s.now.add(_kAfterPrayerAdhkarWindow);
      pauseQuranForAdhan();
    }
    final endAt = s.afterPrayerAdhkarEndsAt;
    if (s.isAfterPrayerAdhkarPlaying &&
        endAt != null &&
        !s.now.isBefore(endAt)) {
      s.isAfterPrayerAdhkarPlaying = false;
      s.afterPrayerAdhkarEndsAt = null;
      resumeQuranAfterAdhan();
    }
  }

  /// Drives the morning/evening session adhkar takeover scheduled by [stopIqama]
  /// (iqama end + 25 min): starts it (pausing Quran) when its time arrives, and
  /// ends it (resuming Quran) after the display window. The
  /// [isAfterPrayerAdhkarPlaying] guard is defensive — the 25-min delay already
  /// clears the after-prayer window, so the two never overlap.
  void checkSessionAdhkar() {
    final startAt = s.sessionAdhkarStartsAt;
    if (startAt != null &&
        !s.now.isBefore(startAt) &&
        !s.isSessionAdhkarPlaying &&
        !s.isAfterPrayerAdhkarPlaying) {
      s.sessionAdhkarStartsAt = null;
      s.isSessionAdhkarPlaying = true;
      s.sessionAdhkarEndsAt = s.now.add(_kSessionAdhkarWindow);
      pauseQuranForAdhan();
    }
    final endAt = s.sessionAdhkarEndsAt;
    if (s.isSessionAdhkarPlaying && endAt != null && !s.now.isBefore(endAt)) {
      s.isSessionAdhkarPlaying = false;
      s.sessionAdhkarEndsAt = null;
      s.sessionAdhkarCategory = '';
      resumeQuranAfterAdhan();
    }
  }

  /// Ends the session adhkar takeover early when its audio playlist finishes
  /// (relayed from the screen as [PrayerSessionAdhkarStopped]), resuming Quran.
  /// The window in [checkSessionAdhkar] stays as a safety cap if this never runs.
  void stopSessionAdhkar() {
    if (!s.isSessionAdhkarPlaying) return;
    s.isSessionAdhkarPlaying = false;
    s.sessionAdhkarEndsAt = null;
    s.sessionAdhkarCategory = '';
    resumeQuranAfterAdhan();
    notify();
  }
}
