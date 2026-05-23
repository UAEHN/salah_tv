import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/app_settings.dart';
import '../domain/entities/app_settings_mapper.dart';
import 'settings_prefs_keys.dart';

/// SharedPreferences ↔ [AppSettings] codec. Keys live in [PrefsKeys] so this
/// file holds only the round-trip serialization.
AppSettings loadAppSettings(SharedPreferences prefs) =>
    appSettingsFromMap({
      'themeColorKey': prefs.getString(PrefsKeys.theme),
      'use24HourFormat': prefs.getBool(PrefsKeys.h24),
      'adhanMode': prefs.getString(PrefsKeys.adhanMode),
      'iqamaMode': prefs.getString(PrefsKeys.iqamaMode),
      'isMosqueMode': prefs.getBool(PrefsKeys.mosqueMode),
      // Legacy bool keys — read so the mapper can migrate old installs.
      'playAdhan': prefs.getBool(PrefsKeys.adhan),
      'playIqama': prefs.getBool(PrefsKeys.iqama2),
      'isDarkMode': prefs.getBool(PrefsKeys.dark),
      'themeMode': prefs.getString(PrefsKeys.themeMode),
      'iqamaDelays': prefs.getString(PrefsKeys.iqama),
      'adhanOffsets': prefs.getString(PrefsKeys.adhanOff),
      'hadithText': prefs.getString(PrefsKeys.hadithText),
      'hadithSource': prefs.getString(PrefsKeys.hadithSrc),
      'fontFamily': prefs.getString(PrefsKeys.font),
      'locale': prefs.getString(PrefsKeys.locale),
      'isQuranEnabled': prefs.getBool(PrefsKeys.quranEnabled),
      'quranReciterName': prefs.getString(PrefsKeys.reciterName),
      'quranReciterServerUrl': prefs.getString(PrefsKeys.reciterUrl),
      'favoriteReciterServerUrls': prefs.getString(PrefsKeys.favReciters),
      'selectedCountry': prefs.getString(PrefsKeys.country),
      'selectedCity': prefs.getString(PrefsKeys.city),
      'selectedLatitude': prefs.getDouble(PrefsKeys.lat),
      'selectedLongitude': prefs.getDouble(PrefsKeys.lng),
      'calculationMethod': prefs.getString(PrefsKeys.calcMethod),
      'madhab': prefs.getString(PrefsKeys.madhab),
      'isCalculatedLocation': prefs.getBool(PrefsKeys.isCalc),
      'selectedTimeZoneId': prefs.getString(PrefsKeys.tzId),
      'utcOffsetHours': prefs.getDouble(PrefsKeys.utcOff),
      'layoutStyle': prefs.getString(PrefsKeys.layout),
      'adhanSound': prefs.getString(PrefsKeys.adhanSound),
      'isAnalogClock': prefs.getBool(PrefsKeys.analog),
      'isAdhkarEnabled': prefs.getBool(PrefsKeys.adhkar),
      'prayerNotificationEnabled': prefs.getString(PrefsKeys.prayerNotif),
      'preAdhanReminderEnabled': prefs.getString(PrefsKeys.preAdhanMap),
      'preAdhanReminderMinutes': prefs.getInt(PrefsKeys.preAdhanMin),
      'iqamaNotificationEnabled': prefs.getString(PrefsKeys.iqamaNotif),
      'preIqamaReminderEnabled': prefs.getString(PrefsKeys.preIqamaMap),
      'preIqamaReminderMinutes': prefs.getInt(PrefsKeys.preIqamaMin),
      'isMorningAdhkarNotificationEnabled':
          prefs.getBool(PrefsKeys.morningAdhkarNotif),
      'isEveningAdhkarNotificationEnabled':
          prefs.getBool(PrefsKeys.eveningAdhkarNotif),
      'morningAdhkarMinuteOfDay':
          prefs.getInt(PrefsKeys.morningAdhkarMinuteOfDay),
      'eveningAdhkarMinuteOfDay':
          prefs.getInt(PrefsKeys.eveningAdhkarMinuteOfDay),
      'isAlKahfReminderEnabled':
          prefs.getBool(PrefsKeys.alKahfReminder),
      'alKahfReminderMinuteOfDay':
          prefs.getInt(PrefsKeys.alKahfReminderMinuteOfDay),
      'isNotificationOnboardingDone':
          prefs.getBool(PrefsKeys.notifOnboardingDone),
      'customAdhans': prefs.getString(PrefsKeys.customAdhans),
      'quranPlaybackMode': prefs.getString(PrefsKeys.playbackMode),
      'selectedSurahNumber': prefs.getInt(PrefsKeys.selectedSurah),
      'surahPlaylist': prefs.getString(PrefsKeys.playlist),
      'surahRepeatCount': prefs.getInt(PrefsKeys.repeatCount),
      'playlistCycleCount': prefs.getInt(PrefsKeys.cycleCount),
      'continuousStartMode': prefs.getString(PrefsKeys.continuousStart),
      'lastPlayedSurah': prefs.getInt(PrefsKeys.lastPlayed),
    });

Future<void> saveAppSettings(SharedPreferences prefs, AppSettings s) async {
  await prefs.setString(PrefsKeys.theme, s.themeColorKey);
  await prefs.setBool(PrefsKeys.h24, s.use24HourFormat);
  await prefs.setString(PrefsKeys.adhanMode, s.adhanMode.name);
  await prefs.setString(PrefsKeys.iqamaMode, s.iqamaMode.name);
  await prefs.setBool(PrefsKeys.mosqueMode, s.isMosqueMode);
  // Drop the legacy bool keys once migrated, so a downgrade doesn't clobber
  // a `silent` choice with a stale `true`.
  await prefs.remove(PrefsKeys.adhan);
  await prefs.remove(PrefsKeys.iqama2);
  await prefs.setBool(PrefsKeys.dark, s.isDarkMode);
  await prefs.setString(PrefsKeys.themeMode, s.themeMode);
  await prefs.setString(PrefsKeys.iqama, jsonEncode(s.iqamaDelays));
  await prefs.setString(PrefsKeys.adhanOff, jsonEncode(s.adhanOffsets));
  await prefs.setString(PrefsKeys.hadithText, s.hadithText);
  await prefs.setString(PrefsKeys.hadithSrc, s.hadithSource);
  await prefs.setString(PrefsKeys.font, s.fontFamily);
  await prefs.setString(PrefsKeys.locale, s.locale);
  await prefs.setBool(PrefsKeys.quranEnabled, s.isQuranEnabled);
  await prefs.setString(PrefsKeys.reciterName, s.quranReciterName);
  await prefs.setString(PrefsKeys.reciterUrl, s.quranReciterServerUrl);
  await prefs.setString(
    PrefsKeys.favReciters,
    jsonEncode(s.favoriteReciterServerUrls),
  );
  await prefs.setString(PrefsKeys.country, s.selectedCountry);
  await prefs.setString(PrefsKeys.city, s.selectedCity);
  await setOrRemoveDouble(prefs, PrefsKeys.lat, s.selectedLatitude);
  await setOrRemoveDouble(prefs, PrefsKeys.lng, s.selectedLongitude);
  await prefs.setString(PrefsKeys.calcMethod, s.calculationMethod);
  await prefs.setString(PrefsKeys.madhab, s.madhab);
  await prefs.setBool(PrefsKeys.isCalc, s.isCalculatedLocation);
  await setOrRemoveString(prefs, PrefsKeys.tzId, s.selectedTimeZoneId);
  await setOrRemoveDouble(prefs, PrefsKeys.utcOff, s.utcOffsetHours);
  await prefs.setString(PrefsKeys.layout, s.layoutStyle);
  await prefs.setString(PrefsKeys.adhanSound, s.adhanSound);
  await prefs.setBool(PrefsKeys.analog, s.isAnalogClock);
  await prefs.setBool(PrefsKeys.adhkar, s.isAdhkarEnabled);
  await prefs.setString(
    PrefsKeys.prayerNotif,
    jsonEncode(s.prayerNotificationEnabled),
  );
  await prefs.setString(
    PrefsKeys.preAdhanMap,
    jsonEncode(s.preAdhanReminderEnabled),
  );
  await prefs.setInt(PrefsKeys.preAdhanMin, s.preAdhanReminderMinutes);
  await prefs.setString(
    PrefsKeys.iqamaNotif,
    jsonEncode(s.iqamaNotificationEnabled),
  );
  await prefs.setString(
    PrefsKeys.preIqamaMap,
    jsonEncode(s.preIqamaReminderEnabled),
  );
  await prefs.setInt(PrefsKeys.preIqamaMin, s.preIqamaReminderMinutes);
  await prefs.setBool(
    PrefsKeys.morningAdhkarNotif,
    s.isMorningAdhkarNotificationEnabled,
  );
  await prefs.setBool(
    PrefsKeys.eveningAdhkarNotif,
    s.isEveningAdhkarNotificationEnabled,
  );
  await prefs.setInt(
    PrefsKeys.morningAdhkarMinuteOfDay,
    s.morningAdhkarMinuteOfDay,
  );
  await prefs.setInt(
    PrefsKeys.eveningAdhkarMinuteOfDay,
    s.eveningAdhkarMinuteOfDay,
  );
  await prefs.setBool(
    PrefsKeys.alKahfReminder,
    s.isAlKahfReminderEnabled,
  );
  await prefs.setInt(
    PrefsKeys.alKahfReminderMinuteOfDay,
    s.alKahfReminderMinuteOfDay,
  );
  await prefs.setBool(
    PrefsKeys.notifOnboardingDone,
    s.isNotificationOnboardingDone,
  );
  await prefs.setString(
    PrefsKeys.customAdhans,
    jsonEncode(s.customAdhans.map((c) => c.toJson()).toList()),
  );
  await prefs.setString(PrefsKeys.playbackMode, s.quranPlaybackMode.name);
  await setOrRemoveInt(prefs, PrefsKeys.selectedSurah, s.selectedSurahNumber);
  await prefs.setString(PrefsKeys.playlist, jsonEncode(s.surahPlaylist));
  await prefs.setInt(PrefsKeys.repeatCount, s.surahRepeatCount);
  await prefs.setInt(PrefsKeys.cycleCount, s.playlistCycleCount);
  await prefs.setString(
    PrefsKeys.continuousStart,
    s.continuousStartMode.name,
  );
  await prefs.setInt(PrefsKeys.lastPlayed, s.lastPlayedSurah);
}
