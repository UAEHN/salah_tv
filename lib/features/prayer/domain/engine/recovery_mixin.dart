import '../../../../core/diagnostics/diagnostic_level.dart';
import '../../../settings/domain/entities/prayer_sound_mode.dart';
import '../entities/daily_prayer_times.dart';
import '../prayer_time_calculator.dart' as calc;
import 'prayer_cycle_base.dart';
import 'prayer_diagnostics_extension.dart';
import 'quran_mixin.dart';
import 'takbeerat_mixin.dart';

/// Delay from app-open before the recovered session adhkar takeover appears.
/// Short, so the user sees the adhkar shortly after opening, but not instantly
/// over the home screen they just landed on.
const Duration _kSessionAdhkarRecoveryDelay = Duration(minutes: 1);

/// How long before Maghrib the evening session window closes for the catch-up.
/// Mirrors the user-requested «قبل المغرب بـ15 دقيقة» cutoff.
const Duration _kEveningWindowEndBeforeMaghrib = Duration(minutes: 15);

/// Handles iqama recovery when the app resumes after missing a prayer trigger.
/// Issue 8: marks all missed prayers to prevent duplicate adhan fires.
mixin RecoveryMixin on PrayerCycleBase, QuranMixin, TakbeeratMixin {
  /// Checks if we are in the iqama-countdown window for a prayer whose
  /// adhan trigger was missed (app was killed or suspended at prayer time).
  /// If so, starts the countdown with the remaining seconds.
  void recoverIqamaState() {
    if (s.todayPrayers == null) return;
    // Do not interfere if a cycle is already in progress
    if (s.isCycleActive) {
      _diagRecovery('skip_cycle_active');
      return;
    }

    final missed = markMissedPrayers();
    if (missed == null) {
      _diagRecovery('skip_no_missed');
      return;
    }

    // Adhan fully off (and not in mosque mode) — live triggers skip the
    // cycle entirely, so recovery has nothing to surface either.
    if (settings.adhanMode == PrayerSoundMode.off && !settings.isMosqueMode) {
      _diagRecovery('skip_adhan_off', {'prayer_key': missed.key});
      return;
    }
    // Iqama fully off (and not in mosque mode) — nothing to recover for the
    // iqama phase.
    if (settings.iqamaMode == PrayerSoundMode.off && !settings.isMosqueMode) {
      _diagRecovery('skip_iqama_off', {'prayer_key': missed.key});
      return;
    }

    final iqamaDelayMin = settings.iqamaDelays[missed.key] ?? 0;

    // Iqama target = adjusted prayer time + iqama delay. Floored to a whole
    // second (already whole-minute here) so every iqamaDueAt set-site holds the
    // same invariant and the countdown steps in lockstep with the clock.
    final prayerAt = calc.adjustedPrayerTime(missed, settings.adhanOffsets);
    final iqamaAt = calc.floorToSecond(
      prayerAt.add(Duration(minutes: iqamaDelayMin)),
    );
    final remaining = iqamaAt.difference(s.now);

    if (remaining.inSeconds > 0) {
      // Still inside the iqama countdown window — show it
      analytics?.logIqamaRecovered(
        prayerKey: missed.key,
        remainingSeconds: remaining.inSeconds,
      );
      s.isIqamaCountdown = true;
      s.iqamaCountdown = remaining;
      s.iqamaDueAt = iqamaAt;
      s.iqamaPrayerKey = missed.key;
      s.currentAdhanPrayerKey = missed.key;
      s.activeCyclePrayerKey = missed.key; // lock card highlight on recovery
      // Store the anchor + delay so a later iqama-delay change recomputes this
      // recovered countdown too — SettingsMixin.updateSettings guards its
      // recalculation on adhanTriggerTime != null, matching the live adhan path.
      s.adhanTriggerTime = prayerAt;
      s.currentIqamaDelayMin = iqamaDelayMin;
      // Pause background audio for the recovered cycle, exactly as the live
      // adhan does. The app missed the adhan while the engine was suspended, so
      // pauseQuranForAdhan was never reached — without this the Quran/Takbeerat
      // keep playing UNDER the recovered iqama and its call overlaps them.
      pauseQuranForAdhan();
      pauseTakbeeratForCycle();
      _diagRecovery('applied', {
        'prayer_key': missed.key,
        'remaining_sec': remaining.inSeconds,
        'iqama_delay_min': iqamaDelayMin,
      });
    } else {
      // Iqama window already closed — nothing to show, cycle drops to next.
      _diagRecovery('skip_window_closed', {
        'prayer_key': missed.key,
        'over_sec': -remaining.inSeconds,
        'iqama_delay_min': iqamaDelayMin,
      });
      // The prayer is fully skipped (no adhan, no iqama) — surface it in the
      // unified no-sound signal. Not critical: reaching here means the engine
      // was suspended/jumped past the whole 5-min rescue + iqama window (a
      // background/frozen box waking late), not a live ticking failure.
      final overSec = s.now.difference(prayerAt).inSeconds;
      diagAdhanNotSounded(
        prayerKey: missed.key,
        cause: 'recovery_window_closed',
        iqamaWillFire: false,
        lateSeconds: overSec,
      );
    }
  }

  // TEMP DIAGNOSTIC — remove after the background iqama-drop is root-caused.
  // Force-uploads exactly which recovery branch ran on resume so the silent
  // iqama-drop culprit is visible in the Control Room trail (this whole path
  // emitted nothing before). See project-bg-adhan-cycle-cascade.
  void _diagRecovery(String outcome, [Map<String, Object?> extra = const {}]) {
    diag(
      DiagnosticLevel.info,
      'iqama_recovery_$outcome',
      fields: extra,
      forceUpload: true,
    );
  }

  /// Loads today's persisted "session adhkar shown" categories into the
  /// in-memory set so the app-open catch-up survives a full restart. Fire it
  /// (unawaited) on start/resume: it completes in a few ms — well inside the
  /// 1-min catch-up delay — and the fire-time dedup in [checkSessionAdhkar]
  /// catches the rare case where it lands after [recoverSessionAdhkar] scheduled.
  Future<void> hydrateSessionAdhkarShown() async {
    final port = sessionAdhkarLog;
    if (port == null) return;
    final shown = await port.shownOn(calc.dateKey(s.now));
    if (shown.isNotEmpty) s.sessionAdhkarShownToday.addAll(shown);
  }

  /// App-open catch-up for the morning/evening session adhkar: schedules the
  /// takeover ~1 min after open when we land inside an adhkar window that the
  /// app missed because it was closed during Fajr/Asr. The live cycle's own
  /// [stopIqama] still schedules it when the app *is* open at prayer time —
  /// this only fills the gap, deduped per day via [sessionAdhkarShownToday].
  void recoverSessionAdhkar() {
    if (s.todayPrayers == null) return;
    // Gated by the master adhkar toggle; never shown in mosque mode (the imam
    // leads it live), matching the live [IqamaMixin.stopIqama] gate.
    if (!settings.isAdhkarEnabled || settings.isMosqueMode) return;
    // A live cycle owns the screen and schedules the session itself — stay out.
    if (s.isCycleActive) return;
    // Already scheduled (live path), already on screen, or already shown today.
    if (s.sessionAdhkarStartsAt != null || s.isSessionAdhkarPlaying) return;
    // Never overlap the «دعاء بعد الصلاة» takeover (its own schedule/window).
    if (s.afterPrayerAdhkarStartsAt != null || s.isAfterPrayerAdhkarPlaying) {
      return;
    }

    final session = _sessionForRecovery();
    if (session.isEmpty) return;
    if (s.sessionAdhkarShownToday.contains(session)) return;

    s.sessionAdhkarCategory = session;
    s.sessionAdhkarStartsAt = s.now.add(_kSessionAdhkarRecoveryDelay);
  }

  /// Which session window the current time falls in, computed from prayer times
  /// directly (not [nextPrayerKey], which may be stale right after a resume).
  /// Morning: after Fajr, before Dhuhr, before 10:00. Evening: after Asr, with
  /// more than 15 min still left before Maghrib. Otherwise ''.
  String _sessionForRecovery() {
    final prayers = s.todayPrayers!.prayersOnly;
    DateTime? timeFor(String key) {
      for (final p in prayers) {
        if (p.key == key) {
          return calc.adjustedPrayerTime(p, settings.adhanOffsets);
        }
      }
      return null;
    }

    final now = s.now;
    final fajr = timeFor('fajr');
    final dhuhr = timeFor('dhuhr');
    final asr = timeFor('asr');
    final maghrib = timeFor('maghrib');

    if (fajr != null &&
        dhuhr != null &&
        !now.isBefore(fajr) &&
        now.isBefore(dhuhr) &&
        now.hour < 10) {
      return 'morning';
    }
    if (asr != null &&
        maghrib != null &&
        !now.isBefore(asr) &&
        now.isBefore(maghrib.subtract(_kEveningWindowEndBeforeMaghrib))) {
      return 'evening';
    }
    return '';
  }

  /// Issue 8: mark missed prayers in adhansToday so checkAdhanTrigger never
  /// re-fires a stale one. Returns the latest missed prayer, or null.
  ///
  /// Only prayers past the live rescue window ([calc.kAdhanRescueCatchUpSeconds])
  /// are "missed": a prayer still inside it (e.g. the device stalled a few
  /// seconds past the moment, tripping the time-jump reload) is left for the
  /// live rescue path to fire, instead of being silently suppressed here.
  PrayerEntry? markMissedPrayers() {
    final result = calc.markMissedPrayers(
      s.todayPrayers!.prayersOnly,
      s.now,
      settings.adhanOffsets,
      s.adhansToday,
      missedAfterSeconds: calc.kAdhanRescueCatchUpSeconds,
    );
    s.adhansToday.addAll(result.newKeys);
    final m = result.missed;
    if (m != null) {
      final delta = s.now
          .difference(calc.adjustedPrayerTime(m, settings.adhanOffsets))
          .inMinutes;
      analytics?.logMissedPrayerDetected(prayerKey: m.key, deltaMinutes: delta);
    }
    return m;
  }
}
