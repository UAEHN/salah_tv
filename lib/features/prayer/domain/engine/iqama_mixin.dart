import 'dart:async';

import '../../../settings/domain/entities/prayer_sound_mode.dart';
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
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
    if (s.iqamaCountdown.inSeconds > 0) {
      s.iqamaCountdown -= const Duration(seconds: 1);
    } else {
      s.isIqamaCountdown = false;
      unawaited(triggerIqama());
    }
  }

  // Issue 3: async so we can detect playIqama() failure and skip to Quran
  // resume immediately rather than waiting for the 4-minute fallback timer.
  Future<void> triggerIqama() async {
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
    s.iqamaFallbackTimer = Timer(window, () {
      if (s.isIqamaPlaying) {
        telIqamaFallback(prayerKey, window.inSeconds, settings.isMosqueMode);
        s.iqamaWasNaturalCompletion = false;
        stopIqama();
      }
    });
    notify();
    if (isSilent) return; // visual-only takeover, no audio
    final success = await audio.playIqama();
    if (!success && s.isIqamaPlaying) {
      telIqamaFail(prayerKey);
      // Audio failed to start — clean up immediately
      s.iqamaFallbackTimer?.cancel();
      s.iqamaWasNaturalCompletion = false;
      await stopIqama();
    }
  }

  // Issue 1: async + await stop() before resuming Quran.
  // Issue 4: entry guard prevents double-call from concurrent onComplete events.
  Future<void> stopIqama() async {
    if (!s.isIqamaPlaying) return;
    telIqamaCompletedFromState(s);
    s.iqamaWasNaturalCompletion = true; // reset for next cycle
    s.isIqamaPlaying = false;
    s.activeCyclePrayerKey = ''; // cycle fully done — release card highlight
    s.iqamaFallbackTimer?.cancel();
    await audio.stop();
    // Mosque mode: open the 10-minute post-iqama prayer window so the home
    // screen shows the silence-phone takeover during the actual prayer.
    if (settings.isMosqueMode) {
      s.prayerInProgressEndsAt = s.now.add(_kMosquePrayerWindow);
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
