import 'dart:async';

import '../prayer_time_calculator.dart' as calc;
import 'prayer_cycle_base.dart';
import 'iqama_mixin.dart';
import 'quran_mixin.dart';

/// Handles the adhan → dua phase of the prayer cycle.
/// Issue comments 1, 3, 4, 9, 10 are preserved verbatim.
mixin AdhanCycleMixin on PrayerCycleBase, IqamaMixin, QuranMixin {
  void checkAdhanTrigger() {
    if (s.todayPrayers == null) return;
    final prayers = s.todayPrayers!.prayersOnly;
    for (final p in prayers) {
      final key = '${p.key}_${s.now.day}';
      if (s.adhansToday.contains(key)) continue;
      final diff = s.now.difference(
        calc.adjustedPrayerTime(p, settings.adhanOffsets),
      );
      if (diff.inSeconds >= 0 && diff.inSeconds <= 2) {
        s.adhansToday.add(key);
        unawaited(triggerAdhan(p.name, p.key));
      }
    }
  }

  // Issue 3: async so we can detect playAdhan() failure and clean up
  // state immediately rather than waiting 4 minutes for the fallback timer.
  Future<void> triggerAdhan(String prayerName, String prayerKey) async {
    s.isAdhanPlaying = true;
    s.currentAdhanPrayerName = prayerName;
    s.activeCyclePrayerKey = prayerKey; // lock card highlight for this prayer
    s.currentIqamaDelayMin =
        settings.iqamaDelays[prayerKey] ?? 0; // Issue 9: snapshot
    s.adhanTriggerTime = s.now; // anchor for iqama countdown calculation
    s.isIqamaCountdown = false;

    // Immediately disable Makkah stream audio so it doesn't overlap adhan.
    s.isMakkahStreamAudioActive = false;

    // Pause Quran for adhan/dua/iqama cycle
    pauseQuranForAdhan();

    // Auto-close after 4 minutes max as a fallback
    s.adhanFallbackTimer?.cancel();
    s.adhanFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (s.isAdhanPlaying) stopAdhan();
    });

    notify();

    final success = await audio.playAdhan(soundKey: settings.adhanSound);
    if (!success && s.isAdhanPlaying) {
      // Audio failed to start — cancel fallback and clean up immediately
      s.adhanFallbackTimer?.cancel();
      s.isAdhanPlaying = false;
      resumeQuranAfterAdhan();
      notify();
    }
  }

  // Issue 1: async + await stop() before triggering dua so the stop platform
  // call fully resolves before playDua() opens the same AudioPlayer.
  // Issue 4: entry guard prevents double-invocation from concurrent events.
  Future<void> stopAdhan() async {
    if (!s.isAdhanPlaying) return;
    s.isAdhanPlaying = false;
    s.adhanFallbackTimer?.cancel();
    await audio.stop();
    // Show dua screen after adhan — fire-and-forget, triggerDua notifies UI
    unawaited(triggerDua());
    notify();
  }

  // Issue 3: async so we can detect playDua() failure and advance directly
  // to the iqama countdown rather than leaving isDuaPlaying=true silently.
  Future<void> triggerDua() async {
    s.isDuaPlaying = true;
    s.duaFallbackTimer?.cancel();
    s.duaFallbackTimer = Timer(const Duration(minutes: 5), () {
      if (s.isDuaPlaying) stopDua();
    });
    notify();
    final success = await audio.playDua();
    if (!success && s.isDuaPlaying) {
      // Audio failed — skip dua and proceed to iqama countdown
      s.duaFallbackTimer?.cancel();
      await stopDua();
    }
  }

  // Issue 1: async + await stop() before starting iqama countdown.
  // Issue 4: entry guard prevents double-invocation.
  // Issue 9: use currentIqamaDelayMin (snapshot) instead of live settings.
  Future<void> stopDua() async {
    if (!s.isDuaPlaying) return;
    s.isDuaPlaying = false;
    s.duaFallbackTimer?.cancel();
    await audio.stop();
    // Start iqama countdown after dua — anchored to adhan trigger time
    // so adhan + dua duration is deducted automatically.
    final delay = s.currentIqamaDelayMin; // Issue 9: snapshotted at adhan fire
    if (delay > 0) {
      s.iqamaPrayerName = s.currentAdhanPrayerName;
      // Calculate how much of the iqama delay has already elapsed
      // since the adhan started (adhan duration + dua duration).
      Duration remaining = Duration(minutes: delay);
      if (s.adhanTriggerTime != null) {
        final elapsed = s.now.difference(s.adhanTriggerTime!);
        remaining = Duration(minutes: delay) - elapsed;
      }
      if (remaining.inSeconds > 0) {
        s.isIqamaCountdown = true;
        s.iqamaCountdown = remaining;
      } else {
        // Iqama window already passed — trigger immediately
        unawaited(triggerIqama());
      }
    }
    notify();
  }

  // Issue 1: await audio.stop() so platform call completes before flag reset.
  Future<void> resetAdhanCycleForCityChange() async {
    s.adhansToday.clear();
    s.adhanFallbackTimer?.cancel();
    s.duaFallbackTimer?.cancel();
    s.iqamaFallbackTimer?.cancel();
    if (s.isCycleActive) await audio.stop();
    s.isAdhanPlaying = false;
    s.currentAdhanPrayerName = '';
    s.activeCyclePrayerKey = '';
    s.currentIqamaDelayMin = 0;
    s.adhanTriggerTime = null;
    s.isIqamaCountdown = false;
    s.iqamaCountdown = Duration.zero;
    s.iqamaPrayerName = '';
    s.isIqamaPlaying = false;
    s.isDuaPlaying = false;
    resumeQuranAfterAdhan();
  }
}
