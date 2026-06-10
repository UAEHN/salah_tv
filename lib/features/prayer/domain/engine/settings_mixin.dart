import 'dart:async';

import '../../../settings/domain/entities/app_settings.dart';
import '../prayer_time_calculator.dart' as calc;
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
import 'adhan_cycle_mixin.dart';
import 'iqama_mixin.dart';
import 'quran_mixin.dart';
import 'recovery_mixin.dart';
import 'tick_mixin.dart';

/// Handles settings propagation and city/country change resets.
mixin SettingsMixin
    on
        PrayerCycleBase,
        AdhanCycleMixin,
        IqamaMixin,
        QuranMixin,
        RecoveryMixin,
        TickMixin {
  /// Called via bridge when settings change. Async because city/country reset
  /// must await audio.stop() before clearing flags (Issue 1 guard).
  Future<void> updateSettings(AppSettings newSettings) async {
    if (s.isCycleActive) {
      telSettingsChangeDuringCycle(activeCyclePhase(s), 'settings_update');
    }
    final oldUrl = settings.quranReciterServerUrl;
    final oldCity = settings.selectedCity;
    final oldCountry = settings.selectedCountry;
    final oldMethod = settings.calculationMethod;
    final oldMadhab = settings.madhab;
    final oldHighLatRule = settings.highLatitudeRule;
    final oldAdhanSound = settings.adhanSound;
    final oldMode = settings.quranPlaybackMode;
    final oldSurah = settings.selectedSurahNumber;
    final oldPlaylist = settings.surahPlaylist.toString();
    final oldRepeatCount = settings.surahRepeatCount;
    final oldCycleCount = settings.playlistCycleCount;
    final oldMorningAdhkar = settings.isMorningAdhkarNotificationEnabled;
    final oldEveningAdhkar = settings.isEveningAdhkarNotificationEnabled;
    final oldMorningMinute = settings.morningAdhkarMinuteOfDay;
    final oldEveningMinute = settings.eveningAdhkarMinuteOfDay;
    final oldAlKahfEnabled = settings.isAlKahfReminderEnabled;
    final oldAlKahfMinute = settings.alKahfReminderMinuteOfDay;
    final mosqueJustEnabled =
        newSettings.isMosqueMode && !settings.isMosqueMode;
    settings = newSettings;
    if (mosqueJustEnabled && s.isQuranPlaying) {
      stopQuranAndClear();
    }
    s.now = currentTime();

    // Reload prayer times when location or calculation parameters change.
    // calculationMethod / madhab / highLatitudeRule: syncPrayerRepositoryMode
    // already re-inits the calcRepo cache before this runs, so loadToday picks
    // up new values. Without highLatitudeRule here, changing the rule in
    // settings would refresh the cache but the engine would keep showing the
    // pre-change todayPrayers until the next manual reload.
    final isCalcChange =
        newSettings.calculationMethod != oldMethod ||
        newSettings.madhab != oldMadhab ||
        newSettings.highLatitudeRule != oldHighLatRule;

    if (newSettings.selectedCity != oldCity ||
        newSettings.selectedCountry != oldCountry ||
        isCalcChange) {
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
      // Re-schedule notifications when the adhan sound changes: Android
      // binds sound at schedule time to a specific channel, so an already-
      // scheduled notification keeps its old sound until cancelled and
      // re-scheduled with the new channel/URI.
      if (newSettings.adhanSound != oldAdhanSound && s.todayPrayers != null) {
        final tomorrowKey = calc.dateKey(
          DateTime(s.now.year, s.now.month, s.now.day + 1),
        );
        unawaited(
          notifications?.scheduleForDay(
            s.todayPrayers!,
            repo.getTomorrowByKey(tomorrowKey),
            settings,
          ),
        );
      }
      // Re-schedule the 7-day adhkar window whenever the user toggles
      // morning/evening reminders or changes either chosen wall-clock time.
      final adhkarChanged =
          newSettings.isMorningAdhkarNotificationEnabled != oldMorningAdhkar ||
          newSettings.isEveningAdhkarNotificationEnabled != oldEveningAdhkar ||
          newSettings.morningAdhkarMinuteOfDay != oldMorningMinute ||
          newSettings.eveningAdhkarMinuteOfDay != oldEveningMinute ||
          newSettings.isAlKahfReminderEnabled != oldAlKahfEnabled ||
          newSettings.alKahfReminderMinuteOfDay != oldAlKahfMinute;
      if (adhkarChanged) {
        unawaited(notifications?.scheduleAdhkar(settings));
      }
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

    // Restart Quran if reciter OR playback mode/surah/repeat/playlist changed
    // while Quran is actively playing.
    final reciterChanged =
        newSettings.quranReciterServerUrl.isNotEmpty &&
        newSettings.quranReciterServerUrl != oldUrl;
    final modeChanged =
        newSettings.quranPlaybackMode != oldMode ||
        newSettings.selectedSurahNumber != oldSurah ||
        newSettings.surahPlaylist.toString() != oldPlaylist ||
        newSettings.surahRepeatCount != oldRepeatCount ||
        newSettings.playlistCycleCount != oldCycleCount;
    if (s.isQuranPlaying &&
        !s.isQuranPausedForAdhan &&
        !s.isQuranPausedByUser &&
        (reciterChanged || modeChanged)) {
      // Hard-reset Quran playback to pick up the new reciter / mode.
      // Use stopQuranAndClear() (not toggleQuran) so we bypass the user-pause
      // branch the toggle now exposes.
      stopQuranAndClear();
      toggleQuran(newSettings.quranReciterServerUrl);
    }

    notify();
  }

  void reload() {
    s.now = currentTime();
    s.adhansToday.clear();
    s.isIqamaCountdown = false;
    loadToday();
    notify();
  }
}
