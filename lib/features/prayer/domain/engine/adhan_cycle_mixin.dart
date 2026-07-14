import 'dart:async';

import '../../../../core/diagnostics/adhan_journey_state.dart';
import '../../../../core/diagnostics/diagnostic_level.dart';
import '../../../settings/domain/entities/prayer_sound_mode.dart';
import '../entities/daily_prayer_times.dart';
import '../prayer_time_calculator.dart' as calc;
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
import 'prayer_diagnostics_extension.dart';
import 'iqama_mixin.dart';
import 'quran_mixin.dart';
import 'takbeerat_mixin.dart';

// Visual takeover windows. Sound mode keeps a 4–5 min fallback for stuck audio.
const Duration _kSilentAdhanWindow = Duration(seconds: 25);
const Duration _kMosqueAdhanWindow = Duration(seconds: 150); // 2:30
const Duration _kSilentDuaWindow = Duration(seconds: 5);

/// Adhan → dua phase. Issue comments 1, 3, 4, 9, 10 preserved verbatim.
mixin AdhanCycleMixin
    on PrayerCycleBase, IqamaMixin, QuranMixin, TakbeeratMixin {
  void checkAdhanTrigger() {
    if (s.todayPrayers == null) return;
    if (s.isCycleActive) return;
    final prayers = s.todayPrayers!.prayersOnly;
    for (final p in prayers) {
      final key = '${p.key}_${s.now.day}';
      if (s.adhansToday.contains(key)) continue;
      final diff = s.now.difference(
        calc.adjustedPrayerTime(p, settings.adhanOffsets),
      );
      // Catch-up window (not just [0,2]s): a stalled tick on a slow TV box
      // could otherwise step over the prayer second and skip the adhan
      // entirely. The `adhansToday` guard above still prevents a double-fire.
      final isLiveWindow = calc.isWithinAdhanFireWindow(diff.inSeconds);
      final isRescueWindow =
          diff.inSeconds > calc.kAdhanCatchUpSeconds &&
          diff.inSeconds <= calc.kAdhanRescueCatchUpSeconds;
      if (isLiveWindow || isRescueWindow) {
        diag(
          isRescueWindow ? DiagnosticLevel.warning : DiagnosticLevel.info,
          isRescueWindow ? 'adhan_rescue_triggered' : 'adhan_due_detected',
          fields: {
            'due_prayer': p.key,
            'diff_sec': diff.inSeconds,
            'rescue': isRescueWindow,
          },
          forceUpload: isRescueWindow,
        );
        s.adhansToday.add(key);
        // Adhan off (and not mosque mode) → mark + skip cycle.
        final off = settings.adhanMode == PrayerSoundMode.off;
        if (off && !settings.isMosqueMode) {
          // Phase 1C.1: surface the skip so the dashboard can tell
          // "user disabled adhan" from "the cycle missed the window".
          final skipKey = 'off_${p.key}_${s.now.day}';
          if (!s.skippedReported.contains(skipKey)) {
            s.skippedReported.add(skipKey);
            telAdhanSkipped(p.key, 'adhan_mode_off');
            telAdhanJourneyState(
              p.key,
              AdhanJourneyState.silentVisualOnly,
              'settings_skip',
              reason: 'adhan_mode_off',
            );
          }
          diag(
            DiagnosticLevel.warning,
            'adhan_skipped_by_settings',
            fields: {'due_prayer': p.key, 'reason': 'adhan_mode_off'},
          );
          continue;
        }
        if (isRescueWindow) {
          // The adhan is a FIXED-INSTANT call to prayer. Past its 30s live
          // window it must NEVER be sounded late — that would call people to a
          // time that already entered. Restore the cycle silently instead of
          // replaying a stale adhan/dua.
          // Benign no-sound: the adhan audio is intentionally suppressed but the
          // prayer is still served (iqama fires on time), so it joins the
          // unified signal flagged iqama_will_fire — distinct from a full skip.
          diagAdhanNotSounded(
            prayerKey: p.key,
            cause: 'rescue_silent',
            iqamaWillFire: true,
            lateSeconds: diff.inSeconds,
          );
          _enterIqamaCountdownForMissedAdhan(p);
        } else {
          unawaited(_guardedTriggerAdhan(p.key));
        }
      }
    }
  }

  /// Enters the iqama phase for a prayer whose adhan window was missed by more
  /// than [calc.kAdhanCatchUpSeconds] (30s). The adhan is a fixed-instant call,
  /// so it is never sounded late; instead the cycle is restored SILENTLY from
  /// the prayer's REAL time — Quran/Takbeerat pause exactly as in the live flow,
  /// and the iqama still fires at its own correct instant (prayer + delay) via
  /// [_setupIqamaCountdown]. The prayer is never dropped; only the mis-timed
  /// call is suppressed.
  void _enterIqamaCountdownForMissedAdhan(PrayerEntry p) {
    s.currentAdhanPrayerKey = p.key;
    s.activeCyclePrayerKey = p.key;
    s.currentIqamaDelayMin = settings.iqamaDelays[p.key] ?? 0; // Issue 9 parity
    // Anchor to the real prayer time (NOT now) so iqama lands at prayer + delay.
    s.adhanTriggerTime = calc.adjustedPrayerTime(p, settings.adhanOffsets);
    s.isAdhanPlaying = false;
    s.isDuaPlaying = false;
    pauseQuranForAdhan();
    pauseTakbeeratForCycle();
    _setupIqamaCountdown();
  }

  /// Called by the engine's onResumed when returning to the app tore down an
  /// adhan/dua that had frozen in the background. recoverIqamaState CANNOT
  /// rebuild the iqama (the prayer is already in adhansToday from the background
  /// fire) — which silently DROPPED it (the iqama vanished mid-countdown, the
  /// card stuck on the fired prayer while the countdown jumped to the next).
  /// The adhan anchor is still set, so advance the cycle straight to its iqama
  /// countdown from that anchor — no dropped iqama, no stale card, no wedged
  /// Quran. Falls back to a clean release if there is no anchor to advance from.
  void advanceToIqamaAfterInterruptedAdhan() {
    if (s.adhanTriggerTime == null) {
      s.activeCyclePrayerKey = '';
      s.currentAdhanPrayerKey = '';
      resumeQuranAfterAdhan();
      resumeTakbeeratAfterCycle();
      return;
    }
    // Close the adhan's health-flow tracker: it reached AUDIO_STARTED and is now
    // waiting for AUDIO_COMPLETED — without this it times out at 5.5 min and
    // FALSELY reports "adhan audio started but did not finish". The adhan DID
    // fire/show/play; the resume teardown is expected, so resolve it as done.
    telAdhanJourneyState(
      s.currentAdhanPrayerKey,
      AdhanJourneyState.audioCompleted,
      'adhan_interrupted_on_resume',
    );
    _setupIqamaCountdown();
  }

  /// [triggerAdhan] is fired unawaited from the tick, so a throw inside it would
  /// vanish as an unhandled zone error with no prayer context — and could leave
  /// the cycle half-set. Wrap it so a failure surfaces named to the exact prayer
  /// instead of disappearing. The wedge guard ([healWedgedCycleIfStuck]) is the
  /// second net that releases any half-set state so it can't block later adhans.
  Future<void> _guardedTriggerAdhan(String prayerKey) async {
    try {
      await triggerAdhan(prayerKey);
    } catch (e, st) {
      diag(
        DiagnosticLevel.error,
        'adhan_trigger_threw',
        fields: {
          'trigger_prayer': prayerKey,
          'error_type': e.runtimeType.toString(),
        },
        error: e,
        stack: st,
        forceUpload: true,
      );
    }
  }

  // Issue 3: async to detect playAdhan() failure. Mosque mode → silent + 150s.
  Future<void> triggerAdhan(String prayerKey) async {
    clearPrayerAlertError();
    s.isAdhanPlaying = true;
    s.currentAdhanPrayerKey = prayerKey;
    s.activeCyclePrayerKey = prayerKey;
    s.currentIqamaDelayMin = settings.iqamaDelays[prayerKey] ?? 0; // Issue 9
    s.adhanTriggerTime = s.now;
    s.isIqamaCountdown = false;
    pauseQuranForAdhan();
    pauseTakbeeratForCycle();
    final mosque = settings.isMosqueMode;
    final isSilent = mosque || settings.adhanMode == PrayerSoundMode.silent;
    final window = mosque
        ? _kMosqueAdhanWindow
        : (isSilent ? _kSilentAdhanWindow : const Duration(minutes: 4));
    telAdhanJourneyState(
      prayerKey,
      AdhanJourneyState.fired,
      'adhan_trigger_started',
    );
    diag(
      DiagnosticLevel.info,
      'adhan_trigger_started',
      fields: {
        'trigger_prayer': prayerKey,
        'silent_visual_only': isSilent,
        'fallback_window_sec': window.inSeconds,
      },
    );
    s.adhanFallbackTimer?.cancel();
    s.adhanFallbackTimer = Timer(window, () {
      if (s.isAdhanPlaying) {
        telAdhanFallback(prayerKey, window.inSeconds);
        telAdhanJourneyState(
          prayerKey,
          AdhanJourneyState.failed,
          'fallback_timeout',
          reason: 'playback_window_expired',
        );
        // No user-facing banner here: by the time this fallback fires the adhan
        // audio has ALREADY started — a genuinely failed/inaudible start is
        // caught inline below in triggerAdhan with its own accurate banner
        // (ADHAN_AUDIO_START_FAILED / ADHAN_MUTED), and silent/mosque mode has no
        // audio at all. Showing "تعذّر تشغيل الأذان" here would be misleading — the
        // call to prayer did sound; we simply never detected its end. The fallback
        // still advances the cycle via stopAdhan.
        //
        // But a SOUND-mode adhan that never signalled completion WHILE the app was
        // on screen is a real failure the user could witness (the takeover hung
        // then jumped on) — escalate that one to a FATAL foreground alert so it
        // never escapes. Silent/mosque mode uses this same timer as its normal
        // advance, and a background miss is expected, so those stay a quiet warning.
        final isIncompleteInForeground = !isSilent && s.isAppInForeground;
        diag(
          isIncompleteInForeground
              ? DiagnosticLevel.fatal
              : DiagnosticLevel.warning,
          isIncompleteInForeground
              ? 'adhan_incomplete_in_foreground'
              : 'adhan_fallback_triggered',
          fields: {
            'trigger_prayer': prayerKey,
            'after_sec': window.inSeconds,
            'is_foreground': s.isAppInForeground,
            'silent': isSilent,
          },
          forceUpload: true,
        );
        stopAdhan();
      }
    });
    notify();
    telAdhanJourneyState(
      prayerKey,
      AdhanJourneyState.notificationShown,
      'visual_takeover_shown',
    );
    if (isSilent) {
      telAdhanJourneyState(
        prayerKey,
        AdhanJourneyState.silentVisualOnly,
        'silent_mode',
        reason: mosque ? 'mosque_mode' : 'adhan_mode_silent',
      );
      diag(
        DiagnosticLevel.info,
        'silent_mode',
        fields: {'trigger_prayer': prayerKey, 'mosque_mode': mosque},
      );
      diag(
        DiagnosticLevel.info,
        'adhan_visual_only',
        fields: {'trigger_prayer': prayerKey},
      );
      return;
    }
    final success = await audio.playAdhan(soundKey: settings.adhanSound);
    if (!success && s.isAdhanPlaying) {
      telAdhanFail(prayerKey);
      telAdhanJourneyState(
        prayerKey,
        AdhanJourneyState.failed,
        'audio_start',
        reason: 'play_returned_false',
      );
      markPrayerAlertError(
        alertType: 'adhan',
        prayerKey: prayerKey,
        code: 'ADHAN_AUDIO_START_FAILED',
        detail: 'sound=${settings.adhanSound}',
      );
      diag(
        DiagnosticLevel.error,
        'audio_failed',
        fields: {
          'trigger_prayer': prayerKey,
          'audio_stage': 'adhan_start',
          'reason': 'play_returned_false',
        },
        forceUpload: true,
      );
      diag(
        DiagnosticLevel.error,
        'adhan_audio_start_failed',
        fields: {'trigger_prayer': prayerKey},
        forceUpload: true,
      );
      s.adhanFallbackTimer?.cancel();
      s.isAdhanPlaying = false;
      resumeQuranAfterAdhan();
      resumeTakbeeratAfterCycle();
      notify();
      return;
    }
    // playAdhan() returning true only means playback started, not that any
    // sound is audible. Probe the device output so a muted / zero-volume TV
    // surfaces as adhan_inaudible — the "screen shows the adhan but I heard
    // nothing" case that looks identical to success in telemetry otherwise.
    if (success && s.isAdhanPlaying) {
      telAdhanJourneyState(
        prayerKey,
        AdhanJourneyState.audioStarted,
        'audio_start',
      );
      diag(
        DiagnosticLevel.info,
        'adhan_audio_start_succeeded',
        fields: {'trigger_prayer': prayerKey},
      );
      final output = await audio.readAudioOutputState();
      if (output != null && output.isInaudible) {
        telAdhanInaudible(
          prayerKey,
          output.volume,
          output.maxVolume,
          output.muted,
        );
        telAdhanJourneyState(
          prayerKey,
          AdhanJourneyState.failed,
          'audio_output_probe',
          reason: output.muted ? 'muted' : 'zero_volume',
        );
        markPrayerAlertError(
          alertType: 'adhan',
          prayerKey: prayerKey,
          code: output.muted ? 'ADHAN_MUTED' : 'ADHAN_ZERO_VOLUME',
          detail: 'volume=${output.volume}/${output.maxVolume}',
        );
        diag(
          DiagnosticLevel.error,
          'audio_failed',
          fields: {
            'trigger_prayer': prayerKey,
            'audio_stage': 'output_probe',
            'volume': output.volume,
            'max_volume': output.maxVolume,
            'muted': output.muted,
          },
          forceUpload: true,
        );
        diag(
          DiagnosticLevel.error,
          'adhan_audio_inaudible',
          fields: {
            'trigger_prayer': prayerKey,
            'volume': output.volume,
            'max_volume': output.maxVolume,
            'muted': output.muted,
            'route': output.route,
            'music_active': output.musicActive,
          },
          forceUpload: true,
        );
      } else if (output != null) {
        // route=='none' means the OS reports NO output device at all — the adhan
        // is silent no matter the volume, a case `isInaudible` (muted/volume only)
        // misses. Escalate to a force-uploaded warning so this "played but nobody
        // heard it" surfaces in the Control Room. Telemetry ONLY — no user banner,
        // no cycle change: a dead-output TV has no viewer to alert, and a probe
        // reading must never risk blocking the cycle.
        final isDeadOutput = output.route == 'none';
        diag(
          isDeadOutput ? DiagnosticLevel.warning : DiagnosticLevel.info,
          isDeadOutput ? 'adhan_dead_output' : 'adhan_audio_output_state',
          fields: {
            'trigger_prayer': prayerKey,
            'volume': output.volume,
            'max_volume': output.maxVolume,
            'muted': output.muted,
            'route': output.route,
            'music_active': output.musicActive,
          },
          forceUpload: isDeadOutput,
        );
      }
    }
  }

  // Issues 1 + 4: await stop() + entry guard. Mosque mode skips dua entirely.
  Future<void> stopAdhan({bool userSkipped = false}) async {
    if (!s.isAdhanPlaying) return;
    telAdhanCompletedFromState(s, userSkipped: userSkipped);
    telAdhanJourneyState(
      s.currentAdhanPrayerKey,
      AdhanJourneyState.audioCompleted,
      'adhan_completed',
    );
    diag(
      DiagnosticLevel.info,
      'adhan_completed',
      fields: {'trigger_prayer': s.currentAdhanPrayerKey},
    );
    s.isAdhanPlaying = false;
    s.adhanFallbackTimer?.cancel();
    await audio.stop();
    if (settings.isMosqueMode) {
      telDuaSkipped(s.currentAdhanPrayerKey, 'mosque_mode');
      diag(
        DiagnosticLevel.info,
        'dua_skipped',
        fields: {'reason': 'mosque_mode'},
      );
      _setupIqamaCountdown();
      return;
    }
    unawaited(triggerDua());
    notify();
  }

  // Issue 3: async — detect playDua() failure to advance to iqama directly.
  Future<void> triggerDua() async {
    s.isDuaPlaying = true;
    s.duaTriggerTime = s.now;
    final isSilent = settings.adhanMode == PrayerSoundMode.silent;
    telDuaStarted(s.currentAdhanPrayerKey, isSilent);
    diag(
      DiagnosticLevel.info,
      'dua_started',
      fields: {'silent_visual_only': isSilent},
    );
    s.duaFallbackTimer?.cancel();
    final win = isSilent ? _kSilentDuaWindow : const Duration(minutes: 5);
    s.duaFallbackTimer = Timer(win, () {
      if (s.isDuaPlaying) stopDua();
    });
    notify();
    if (isSilent) return;
    final success = await audio.playDua();
    if (!success && s.isDuaPlaying) {
      telDuaFail(s.currentAdhanPrayerKey);
      diag(DiagnosticLevel.error, 'dua_audio_start_failed', forceUpload: true);
      s.duaFallbackTimer?.cancel();
      await stopDua();
    }
  }

  // Issues 1, 4, 9: await stop(); entry guard; snapshot delay.
  Future<void> stopDua() async {
    if (!s.isDuaPlaying) return;
    telDuaCompletedFromState(s, s.currentAdhanPrayerKey);
    diag(DiagnosticLevel.info, 'dua_completed');
    s.isDuaPlaying = false;
    s.duaFallbackTimer?.cancel();
    await audio.stop();
    _setupIqamaCountdown();
  }

  // Iqama-phase entry: stopDua() (normal) or stopAdhan() (mosque skip).
  void _setupIqamaCountdown() {
    final iqamaOff = settings.iqamaMode == PrayerSoundMode.off;
    if (iqamaOff && !settings.isMosqueMode) {
      telIqamaCountdownSkipped(s.currentAdhanPrayerKey, 'iqama_mode_off');
      diag(
        DiagnosticLevel.warning,
        'iqama_skipped_by_settings',
        fields: {'reason': 'iqama_mode_off'},
      );
      s.iqamaDueAt = null;
      s.activeCyclePrayerKey = '';
      resumeQuranAfterAdhan();
      resumeTakbeeratAfterCycle();
      notify();
      return;
    }
    final delay = s.currentIqamaDelayMin;
    s.iqamaPrayerKey = s.currentAdhanPrayerKey;
    final anchor = s.adhanTriggerTime ?? s.now;
    // Whole-second target so the countdown steps at .000 in lockstep with the
    // on-screen clock. The anchor carries adhan's sub-second fraction, which
    // otherwise made the shown seconds stall a tick then jump 2 (see
    // calc.floorToSecond).
    final dueAt = calc.floorToSecond(anchor.add(Duration(minutes: delay)));
    s.iqamaDueAt = dueAt;
    if (delay > 0) {
      final remaining = dueAt.difference(s.now);
      if (remaining.inSeconds > 0) {
        s.isIqamaCountdown = true;
        s.iqamaCountdown = remaining;
        telIqamaCountdownStarted(
          s.currentAdhanPrayerKey,
          delay,
          remaining.inSeconds,
        );
        diag(
          DiagnosticLevel.info,
          'iqama_countdown_started',
          fields: {'delay_min': delay, 'remaining_sec': remaining.inSeconds},
        );
      } else {
        diag(
          DiagnosticLevel.info,
          'iqama_countdown_elapsed_immediately',
          fields: {'delay_min': delay},
        );
        unawaited(guardedTriggerIqama());
      }
    } else {
      diag(
        DiagnosticLevel.info,
        'iqama_countdown_elapsed_immediately',
        fields: {'delay_min': delay, 'reason': 'zero_delay'},
      );
      unawaited(guardedTriggerIqama());
    }
    notify();
  }

  // Issue 1: await stop() before flag reset.
  Future<void> resetAdhanCycleForCityChange() async {
    telCycleReset('city_change');
    diag(
      DiagnosticLevel.warning,
      'cycle_reset',
      fields: {'reason': 'city_change'},
    );
    s.adhansToday.clear();
    // Phase 1C.1: dedup sets are scoped to the same calendar/cycle as
    // adhansToday — reset them together so the new city/day starts clean.
    s.overdueReported.clear();
    s.skippedReported.clear();
    s.adhanFallbackTimer?.cancel();
    s.duaFallbackTimer?.cancel();
    s.iqamaFallbackTimer?.cancel();
    if (s.isCycleActive) await audio.stop();
    s.isAdhanPlaying = false;
    s.currentAdhanPrayerKey = '';
    s.activeCyclePrayerKey = '';
    s.currentIqamaDelayMin = 0;
    s.adhanTriggerTime = null;
    s.isIqamaCountdown = false;
    s.iqamaCountdown = Duration.zero;
    s.iqamaDueAt = null;
    s.iqamaPrayerKey = '';
    s.isIqamaPlaying = false;
    s.isDuaPlaying = false;
    s.afterPrayerAdhkarStartsAt = null;
    s.afterPrayerAdhkarEndsAt = null;
    s.isAfterPrayerAdhkarPlaying = false;
    s.sessionAdhkarStartsAt = null;
    s.sessionAdhkarEndsAt = null;
    s.isSessionAdhkarPlaying = false;
    s.sessionAdhkarCategory = '';
    resumeQuranAfterAdhan();
    resumeTakbeeratAfterCycle();
  }
}
