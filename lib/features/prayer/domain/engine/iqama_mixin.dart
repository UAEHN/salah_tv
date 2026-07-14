import 'dart:async';

import '../../../../core/diagnostics/adhan_journey_state.dart';
import '../../../../core/diagnostics/diagnostic_level.dart';
import '../../../settings/domain/entities/prayer_sound_mode.dart';
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
import 'prayer_diagnostics_extension.dart';
import 'quran_mixin.dart';
import 'takbeerat_mixin.dart';

/// Auto-close window for the silent iqama visual takeover (regular silent
/// iqama mode — short notice).
const Duration _kSilentIqamaWindow = Duration(seconds: 12);

/// Auto-close window for the mosque-mode iqama takeover. Held longer so the
/// congregation can read the announcement before the worshipping window opens.
const Duration _kMosqueIqamaWindow = Duration(seconds: 30);

/// Mosque-mode post-iqama prayer window — the after-prayer adhkar takeover
/// begins exactly when it ends (the congregation has finished praying).
const Duration _kMosquePrayerWindow = Duration(minutes: 10);

/// Non-mosque delay from iqama end to the after-prayer adhkar takeover — a
/// rough estimate of how long the prayer itself takes at home.
const Duration _kAfterPrayerDelay = Duration(minutes: 10);

/// Delay from iqama end to the morning/evening session adhkar takeover (~20 min
/// after the prayer itself). Kept INDEPENDENT of the after-prayer dua — which the
/// user can disable — so the session always appears regardless. Still well clear
/// of the after-prayer window (iqama+10..+15) so the two never overlap when both
/// are on. The tick loop ([TickMixin.checkSessionAdhkar]) acts on the time.
const Duration _kSessionAdhkarDelay = Duration(minutes: 30);

/// Handles the iqama countdown and iqama playback phase.
/// Issue comments 1, 3, 4, 10 are preserved verbatim.
mixin IqamaMixin on PrayerCycleBase, QuranMixin, TakbeeratMixin {
  void tickIqama() {
    if (!s.isIqamaCountdown) return;
    final dueAt = s.iqamaDueAt;
    if (dueAt != null) {
      final remaining = dueAt.difference(s.now);
      if (remaining.inSeconds > 0) {
        s.iqamaCountdown = remaining;
        return;
      }
      s.isIqamaCountdown = false;
      s.iqamaCountdown = Duration.zero;
      unawaited(guardedTriggerIqama());
      return;
    }
    if (s.iqamaCountdown.inSeconds > 0) {
      s.iqamaCountdown -= const Duration(seconds: 1);
      return;
    }
    s.isIqamaCountdown = false;
    unawaited(guardedTriggerIqama());
  }

  void checkIqamaRescue() {
    final dueAt = s.iqamaDueAt;
    if (dueAt == null) return;
    if (s.isAdhanPlaying || s.isDuaPlaying || s.isIqamaPlaying) return;
    if (s.now.isBefore(dueAt)) return;
    if (settings.iqamaMode == PrayerSoundMode.off && !settings.isMosqueMode) {
      s.iqamaDueAt = null;
      return;
    }
    s.isIqamaCountdown = false;
    s.iqamaCountdown = Duration.zero;
    diag(
      DiagnosticLevel.warning,
      'iqama_rescue_triggered',
      fields: {
        'trigger_prayer': s.iqamaPrayerKey,
        'late_sec': s.now.difference(dueAt).inSeconds,
      },
      forceUpload: true,
    );
    unawaited(guardedTriggerIqama());
  }

  /// [triggerIqama] is fired unawaited from the tick / rescue / countdown-elapsed
  /// paths, so a throw inside it would vanish as an unhandled zone error and
  /// could leave [isIqamaPlaying] wedged — which keeps the cycle "active" and
  /// silently blocks every future prayer's adhan. Wrap it so a failure is
  /// reported; [healWedgedCycleIfStuck] then releases any wedged state.
  Future<void> guardedTriggerIqama() async {
    try {
      await triggerIqama();
    } catch (e, st) {
      diag(
        DiagnosticLevel.error,
        'iqama_trigger_threw',
        fields: {
          'trigger_prayer': s.iqamaPrayerKey,
          'error_type': e.runtimeType.toString(),
        },
        error: e,
        stack: st,
        forceUpload: true,
      );
    }
  }

  // Issue 3: async so we can detect playIqama() failure and skip to Quran
  // resume immediately rather than waiting for the 4-minute fallback timer.
  Future<void> triggerIqama() async {
    clearPrayerAlertError();
    if (s.isIqamaPlaying) return;
    s.isIqamaCountdown = false;
    s.iqamaCountdown = Duration.zero;
    s.iqamaDueAt = null;
    s.isIqamaPlaying = true;
    s.iqamaTriggerTime = s.now;
    final isSilent =
        settings.isMosqueMode || settings.iqamaMode == PrayerSoundMode.silent;
    s.iqamaFallbackTimer?.cancel();
    final silentWindow = settings.isMosqueMode
        ? _kMosqueIqamaWindow
        : _kSilentIqamaWindow;
    final window = isSilent ? silentWindow : const Duration(minutes: 4);
    final prayerKey = s.iqamaPrayerKey;
    telPrayerAlertJourneyState(
      alertType: 'iqama',
      prayerKey: prayerKey,
      state: AdhanJourneyState.fired,
      stage: 'iqama_trigger_started',
    );
    diag(
      DiagnosticLevel.info,
      'iqama_trigger_started',
      fields: {
        'trigger_prayer': prayerKey,
        'silent_visual_only': isSilent,
        'fallback_window_sec': window.inSeconds,
      },
    );
    s.iqamaFallbackTimer = Timer(window, () {
      if (s.isIqamaPlaying) {
        telIqamaFallback(prayerKey, window.inSeconds, settings.isMosqueMode);
        telPrayerAlertJourneyState(
          alertType: 'iqama',
          prayerKey: prayerKey,
          state: AdhanJourneyState.failed,
          stage: 'fallback_timeout',
          reason: 'playback_window_expired',
        );
        markPrayerAlertError(
          alertType: 'iqama',
          prayerKey: prayerKey,
          code: 'IQAMA_TIMEOUT',
          detail: 'fallback_window=${window.inSeconds}s',
        );
        diag(
          DiagnosticLevel.warning,
          'iqama_fallback_triggered',
          fields: {'trigger_prayer': prayerKey, 'after_sec': window.inSeconds},
          forceUpload: true,
        );
        s.iqamaWasNaturalCompletion = false;
        stopIqama();
      }
    });
    notify();
    telPrayerAlertJourneyState(
      alertType: 'iqama',
      prayerKey: prayerKey,
      state: AdhanJourneyState.notificationShown,
      stage: 'visual_takeover_shown',
    );
    if (isSilent) {
      telPrayerAlertJourneyState(
        alertType: 'iqama',
        prayerKey: prayerKey,
        state: AdhanJourneyState.silentVisualOnly,
        stage: 'silent_mode',
        reason: settings.isMosqueMode ? 'mosque_mode' : 'iqama_mode_silent',
      );
      diag(
        DiagnosticLevel.info,
        'silent_mode',
        fields: {
          'trigger_prayer': prayerKey,
          'alert_type': 'iqama',
          'mosque_mode': settings.isMosqueMode,
        },
      );
      diag(
        DiagnosticLevel.info,
        'iqama_visual_only',
        fields: {'trigger_prayer': prayerKey},
      );
      return; // visual-only takeover, no audio
    }
    final success = await audio.playIqama(soundKey: settings.iqamaSound);
    if (!success && s.isIqamaPlaying) {
      telIqamaFail(prayerKey);
      telPrayerAlertJourneyState(
        alertType: 'iqama',
        prayerKey: prayerKey,
        state: AdhanJourneyState.failed,
        stage: 'audio_start',
        reason: 'play_returned_false',
      );
      markPrayerAlertError(
        alertType: 'iqama',
        prayerKey: prayerKey,
        code: 'IQAMA_AUDIO_START_FAILED',
      );
      diag(
        DiagnosticLevel.error,
        'audio_failed',
        fields: {
          'trigger_prayer': prayerKey,
          'alert_type': 'iqama',
          'audio_stage': 'iqama_start',
          'reason': 'play_returned_false',
        },
        forceUpload: true,
      );
      diag(
        DiagnosticLevel.error,
        'iqama_audio_start_failed',
        fields: {'trigger_prayer': prayerKey},
        forceUpload: true,
      );
      // Audio failed to start — clean up immediately
      s.iqamaFallbackTimer?.cancel();
      s.iqamaWasNaturalCompletion = false;
      await stopIqama();
      return;
    }
    if (success && s.isIqamaPlaying) {
      telPrayerAlertJourneyState(
        alertType: 'iqama',
        prayerKey: prayerKey,
        state: AdhanJourneyState.audioStarted,
        stage: 'audio_start',
      );
      diag(
        DiagnosticLevel.info,
        'iqama_audio_start_succeeded',
        fields: {'trigger_prayer': prayerKey},
      );
      // Mirror the adhan output probe: playIqama() returning true means playback
      // started, NOT that any sound is audible. Probe the device so a muted /
      // zero-volume / dead-output (HDMI off) iqama surfaces instead of looking
      // identical to success in telemetry.
      final output = await audio.readAudioOutputState();
      if (output != null && output.isInaudible) {
        telPrayerAlertJourneyState(
          alertType: 'iqama',
          prayerKey: prayerKey,
          state: AdhanJourneyState.failed,
          stage: 'audio_output_probe',
          reason: output.muted ? 'muted' : 'zero_volume',
        );
        markPrayerAlertError(
          alertType: 'iqama',
          prayerKey: prayerKey,
          code: output.muted ? 'IQAMA_MUTED' : 'IQAMA_ZERO_VOLUME',
          detail: 'volume=${output.volume}/${output.maxVolume}',
        );
        diag(
          DiagnosticLevel.error,
          'iqama_audio_inaudible',
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
        // route=='none' means NO output device at all — silent no matter the
        // volume, a case `isInaudible` (muted/volume only) misses. Escalate to a
        // force-uploaded warning so it surfaces in the Control Room. Telemetry
        // ONLY — no user banner, no cycle change (parity with the adhan probe).
        final isDeadOutput = output.route == 'none';
        diag(
          isDeadOutput ? DiagnosticLevel.warning : DiagnosticLevel.info,
          isDeadOutput ? 'iqama_dead_output' : 'iqama_audio_output_state',
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

  // Issue 1: async + await stop() before resuming Quran.
  // Issue 4: entry guard prevents double-call from concurrent onComplete events.
  Future<void> stopIqama({bool userSkipped = false}) async {
    if (!s.isIqamaPlaying) return;
    telIqamaCompletedFromState(s, userSkipped: userSkipped);
    telPrayerAlertJourneyState(
      alertType: 'iqama',
      prayerKey: s.iqamaPrayerKey,
      state: AdhanJourneyState.audioCompleted,
      stage: 'iqama_completed',
    );
    diag(
      DiagnosticLevel.info,
      'iqama_completed',
      fields: {'trigger_prayer': s.iqamaPrayerKey},
    );
    s.iqamaWasNaturalCompletion = true; // reset for next cycle
    s.isIqamaPlaying = false;
    s.iqamaDueAt = null;
    s.activeCyclePrayerKey = ''; // cycle fully done — release card highlight
    s.iqamaFallbackTimer?.cancel();
    await audio.stop();
    // Mosque mode: open the 10-minute post-iqama prayer window so the home
    // screen shows the silence-phone takeover during the actual prayer.
    if (settings.isMosqueMode) {
      s.prayerInProgressEndsAt = s.now.add(_kMosquePrayerWindow);
      diag(
        DiagnosticLevel.info,
        'mosque_prayer_window_started',
        fields: {'duration_min': _kMosquePrayerWindow.inMinutes},
      );
    }
    // Schedule the after-prayer adhkar takeover (gated by the adhkar setting
    // and its own dedicated toggle, so it can be turned off without disabling
    // the morning/evening session adhkar). Mosque: it begins right when the
    // prayer window above ends. Non-mosque: after a rough prayer-duration delay.
    // The tick loop starts/ends it.
    if (settings.isAdhkarEnabled && settings.isAfterPrayerAdhkarEnabled) {
      s.afterPrayerAdhkarStartsAt = s.now.add(
        settings.isMosqueMode ? _kMosquePrayerWindow : _kAfterPrayerDelay,
      );
    }
    // Schedule the morning/evening session adhkar takeover ~20 min after the
    // prayer (after Fajr → morning, after Asr → evening). INDEPENDENT of the
    // after-prayer dua — it fires on its own iqama-relative delay so disabling
    // the after-prayer dua never affects it. Never scheduled in mosque mode:
    // the imam leads adhkar live, so the takeover must not appear there.
    if (settings.isAdhkarEnabled && !settings.isMosqueMode) {
      final session = _sessionForCurrentPrayer();
      if (session.isNotEmpty) {
        s.sessionAdhkarCategory = session;
        s.sessionAdhkarStartsAt = s.now.add(_kSessionAdhkarDelay);
      }
    }
    // Resume Quran after iqama ends
    resumeQuranAfterAdhan();
    resumeTakbeeratAfterCycle();
    notify();
  }

  /// Which morning/evening adhkar session applies at iqama end, or '' if none.
  /// After Fajr the next prayer is Dhuhr (before 10:00 → morning); after Asr the
  /// next is Maghrib (still > 5 min away → evening). Other prayers → no session.
  String _sessionForCurrentPrayer() {
    if (s.nextPrayerKey == 'dhuhr' && s.now.hour < 10) return 'morning';
    if (s.nextPrayerKey == 'maghrib' && s.countdown.inMinutes > 5) {
      return 'evening';
    }
    return '';
  }
}
