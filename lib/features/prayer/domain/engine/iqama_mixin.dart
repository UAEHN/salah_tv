import 'dart:async';

import 'prayer_cycle_base.dart';
import 'quran_mixin.dart';

/// Handles the iqama countdown and iqama playback phase.
/// Issue comments 1, 3, 4, 10 are preserved verbatim.
mixin IqamaMixin on PrayerCycleBase, QuranMixin {
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
    s.iqamaFallbackTimer?.cancel();
    s.iqamaFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (s.isIqamaPlaying) stopIqama();
    });
    notify();
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
    // Resume Quran after iqama ends
    resumeQuranAfterAdhan();
    notify();
  }

}
