import 'dart:async';

import '../../../settings/domain/entities/prayer_sound_mode.dart';
import '../prayer_time_calculator.dart' as calc;
import 'prayer_cycle_base.dart';
import 'iqama_mixin.dart';
import 'quran_mixin.dart';
import 'takbeerat_mixin.dart';

// Visual takeover windows. Sound mode keeps a 4–5 min fallback for stuck audio.
const Duration _kSilentAdhanWindow = Duration(seconds: 25);
const Duration _kMosqueAdhanWindow = Duration(seconds: 150); // 2:30
const Duration _kSilentDuaWindow = Duration(seconds: 5);

/// Adhan → dua phase. Issue comments 1, 3, 4, 9, 10 preserved verbatim.
mixin AdhanCycleMixin on PrayerCycleBase, IqamaMixin, QuranMixin, TakbeeratMixin {
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
        // Adhan off (and not mosque mode) → mark + skip cycle.
        final off = settings.adhanMode == PrayerSoundMode.off;
        if (off && !settings.isMosqueMode) continue;
        unawaited(triggerAdhan(p.key));
      }
    }
  }

  // Issue 3: async to detect playAdhan() failure. Mosque mode → silent + 150s.
  Future<void> triggerAdhan(String prayerKey) async {
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
    s.adhanFallbackTimer?.cancel();
    s.adhanFallbackTimer =
        Timer(window, () { if (s.isAdhanPlaying) stopAdhan(); });
    notify();
    if (isSilent) return;
    final success = await audio.playAdhan(soundKey: settings.adhanSound);
    if (!success && s.isAdhanPlaying) {
      s.adhanFallbackTimer?.cancel();
      s.isAdhanPlaying = false;
      resumeQuranAfterAdhan();
      resumeTakbeeratAfterCycle();
      notify();
    }
  }

  // Issues 1 + 4: await stop() + entry guard. Mosque mode skips dua entirely.
  Future<void> stopAdhan() async {
    if (!s.isAdhanPlaying) return;
    s.isAdhanPlaying = false;
    s.adhanFallbackTimer?.cancel();
    await audio.stop();
    if (settings.isMosqueMode) {
      _setupIqamaCountdown();
      return;
    }
    unawaited(triggerDua());
    notify();
  }

  // Issue 3: async — detect playDua() failure to advance to iqama directly.
  Future<void> triggerDua() async {
    s.isDuaPlaying = true;
    final isSilent = settings.adhanMode == PrayerSoundMode.silent;
    s.duaFallbackTimer?.cancel();
    final win = isSilent ? _kSilentDuaWindow : const Duration(minutes: 5);
    s.duaFallbackTimer =
        Timer(win, () { if (s.isDuaPlaying) stopDua(); });
    notify();
    if (isSilent) return;
    final success = await audio.playDua();
    if (!success && s.isDuaPlaying) {
      s.duaFallbackTimer?.cancel();
      await stopDua();
    }
  }

  // Issues 1, 4, 9: await stop(); entry guard; snapshot delay.
  Future<void> stopDua() async {
    if (!s.isDuaPlaying) return;
    s.isDuaPlaying = false;
    s.duaFallbackTimer?.cancel();
    await audio.stop();
    _setupIqamaCountdown();
  }

  // Iqama-phase entry: stopDua() (normal) or stopAdhan() (mosque skip).
  void _setupIqamaCountdown() {
    final iqamaOff = settings.iqamaMode == PrayerSoundMode.off;
    if (iqamaOff && !settings.isMosqueMode) {
      s.activeCyclePrayerKey = '';
      resumeQuranAfterAdhan();
      resumeTakbeeratAfterCycle();
      notify();
      return;
    }
    final delay = s.currentIqamaDelayMin;
    if (delay > 0) {
      s.iqamaPrayerKey = s.currentAdhanPrayerKey;
      var remaining = Duration(minutes: delay);
      if (s.adhanTriggerTime != null) {
        remaining -= s.now.difference(s.adhanTriggerTime!);
      }
      if (remaining.inSeconds > 0) {
        s.isIqamaCountdown = true;
        s.iqamaCountdown = remaining;
      } else {
        unawaited(triggerIqama());
      }
    }
    notify();
  }

  // Issue 1: await stop() before flag reset.
  Future<void> resetAdhanCycleForCityChange() async {
    s.adhansToday.clear();
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
    s.iqamaPrayerKey = '';
    s.isIqamaPlaying = false;
    s.isDuaPlaying = false;
    resumeQuranAfterAdhan();
    resumeTakbeeratAfterCycle();
  }
}
