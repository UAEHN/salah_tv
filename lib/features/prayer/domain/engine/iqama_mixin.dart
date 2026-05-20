import 'dart:async';

import '../../../settings/domain/entities/prayer_sound_mode.dart';
import 'prayer_cycle_base.dart';
import 'quran_mixin.dart';
import 'takbeerat_mixin.dart';

/// Auto-close window for the silent iqama visual takeover (regular silent
/// iqama mode — short notice).
const Duration _kSilentIqamaWindow = Duration(seconds: 12);

/// Auto-close window for the mosque-mode iqama takeover. Held longer so the
/// congregation can read the announcement before the worshipping window opens.
const Duration _kMosqueIqamaWindow = Duration(seconds: 30);

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
    final isSilent = settings.isMosqueMode ||
        settings.iqamaMode == PrayerSoundMode.silent;
    s.iqamaFallbackTimer?.cancel();
    final silentWindow = settings.isMosqueMode
        ? _kMosqueIqamaWindow
        : _kSilentIqamaWindow;
    s.iqamaFallbackTimer = Timer(
      isSilent ? silentWindow : const Duration(minutes: 4),
      () {
        if (s.isIqamaPlaying) stopIqama();
      },
    );
    notify();
    if (isSilent) return; // visual-only takeover, no audio
    final success = await audio.playIqama();
    if (!success && s.isIqamaPlaying) {
      // Audio failed to start — clean up immediately
      s.iqamaFallbackTimer?.cancel();
      await stopIqama();
    }
  }

  // Issue 1: async + await stop() before resuming Quran.
  // Issue 4: entry guard prevents double-call from concurrent onComplete events.
  Future<void> stopIqama() async {
    if (!s.isIqamaPlaying) return;
    s.isIqamaPlaying = false;
    s.activeCyclePrayerKey = ''; // cycle fully done — release card highlight
    s.iqamaFallbackTimer?.cancel();
    await audio.stop();
    // Mosque mode: open the 10-minute post-iqama prayer window so the home
    // screen shows the silence-phone takeover during the actual prayer.
    if (settings.isMosqueMode) {
      s.prayerInProgressEndsAt = s.now.add(const Duration(minutes: 10));
    }
    // Resume Quran after iqama ends
    resumeQuranAfterAdhan();
    resumeTakbeeratAfterCycle();
    notify();
  }

}
