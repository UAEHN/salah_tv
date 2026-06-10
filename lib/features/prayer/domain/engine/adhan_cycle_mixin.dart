import 'dart:async';

import '../../../settings/domain/entities/prayer_sound_mode.dart';
import '../prayer_time_calculator.dart' as calc;
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
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
      if (calc.isWithinAdhanFireWindow(diff.inSeconds)) {
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
          }
          continue;
        }
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
    s.adhanFallbackTimer = Timer(window, () {
      if (s.isAdhanPlaying) {
        telAdhanFallback(prayerKey, window.inSeconds);
        stopAdhan();
      }
    });
    notify();
    if (isSilent) return;
    final success = await audio.playAdhan(soundKey: settings.adhanSound);
    if (!success && s.isAdhanPlaying) {
      telAdhanFail(prayerKey);
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
      final output = await audio.readAudioOutputState();
      if (output != null && output.isInaudible) {
        telAdhanInaudible(
          prayerKey,
          output.volume,
          output.maxVolume,
          output.muted,
        );
      }
    }
  }

  // Issues 1 + 4: await stop() + entry guard. Mosque mode skips dua entirely.
  Future<void> stopAdhan() async {
    if (!s.isAdhanPlaying) return;
    telAdhanCompletedFromState(s);
    s.isAdhanPlaying = false;
    s.adhanFallbackTimer?.cancel();
    await audio.stop();
    if (settings.isMosqueMode) {
      telDuaSkipped(s.currentAdhanPrayerKey, 'mosque_mode');
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
      s.duaFallbackTimer?.cancel();
      await stopDua();
    }
  }

  // Issues 1, 4, 9: await stop(); entry guard; snapshot delay.
  Future<void> stopDua() async {
    if (!s.isDuaPlaying) return;
    telDuaCompletedFromState(s, s.currentAdhanPrayerKey);
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
        telIqamaCountdownStarted(
          s.currentAdhanPrayerKey,
          delay,
          remaining.inSeconds,
        );
      } else {
        unawaited(triggerIqama());
      }
    } else {
      telIqamaCountdownSkipped(s.currentAdhanPrayerKey, 'zero_delay');
    }
    notify();
  }

  // Issue 1: await stop() before flag reset.
  Future<void> resetAdhanCycleForCityChange() async {
    telCycleReset('city_change');
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
