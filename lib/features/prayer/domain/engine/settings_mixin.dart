import 'dart:async';

import '../../../settings/domain/entities/app_settings.dart';
import 'prayer_cycle_base.dart';
import 'adhan_cycle_mixin.dart';
import 'iqama_mixin.dart';
import 'recovery_mixin.dart';
import 'tick_mixin.dart';

/// Handles settings propagation and city/country change resets.
mixin SettingsMixin
    on PrayerCycleBase, AdhanCycleMixin, IqamaMixin, RecoveryMixin, TickMixin {
  /// Called via bridge when settings change. Async because city/country reset
  /// must await audio.stop() before clearing flags (Issue 1 guard).
  Future<void> updateSettings(AppSettings newSettings) async {
    final oldUrl = settings.quranReciterServerUrl;
    final oldCity = settings.selectedCity;
    final oldCountry = settings.selectedCountry;
    settings = newSettings;

    // If city or country changed, reset adhan state and reload prayer times
    if (newSettings.selectedCity != oldCity ||
        newSettings.selectedCountry != oldCountry) {
      await resetAdhanCycleForCityChange();
      repo.setActiveCity(newSettings.selectedCity);
      loadToday();
      s.needsIqamaRecovery = true;
      if (s.todayPrayers != null) {
        recoverIqamaState();
        s.needsIqamaRecovery = false;
      }
    } else {
      updateNextPrayer();
    }

    // If iqama delay changed while the countdown is running, recalculate
    // remaining time from the original adhan trigger anchor.
    if (s.isIqamaCountdown && s.adhanTriggerTime != null) {
      final newDelay = settings.iqamaDelays[s.activeCyclePrayerKey] ?? 0;
      if (newDelay != s.currentIqamaDelayMin) {
        s.currentIqamaDelayMin = newDelay;
        final elapsed = s.now.difference(s.adhanTriggerTime!);
        final remaining = Duration(minutes: newDelay) - elapsed;
        if (remaining.inSeconds > 0) {
          s.iqamaCountdown = remaining;
        } else {
          s.isIqamaCountdown = false;
          unawaited(triggerIqama());
        }
      }
    }

    // If reciter changed while Quran is actively playing, switch immediately
    if (s.isQuranPlaying &&
        !s.isQuranPausedForAdhan &&
        newSettings.quranReciterServerUrl.isNotEmpty &&
        newSettings.quranReciterServerUrl != oldUrl) {
      audio.playQuranFromServer(newSettings.quranReciterServerUrl);
    }

    notify();
  }

  void reload() {
    s.adhansToday.clear();
    s.isIqamaCountdown = false;
    loadToday();
    notify();
  }
}
