import 'dart:convert';

import 'app_settings.dart';
import 'app_settings_decoders.dart';

/// Serialization helpers for [AppSettings] — kept separate to stay within
/// the 150-line file limit while still living in the same domain/entities layer.
extension AppSettingsMapper on AppSettings {
  Map<String, dynamic> toMap() => {
    'themeColorKey': themeColorKey,
    'use24HourFormat': use24HourFormat,
    'adhanMode': adhanMode.name,
    'iqamaMode': iqamaMode.name,
    'isMosqueMode': isMosqueMode,
    'isDarkMode': isDarkMode,
    'iqamaDelays': jsonEncode(iqamaDelays),
    'adhanOffsets': jsonEncode(adhanOffsets),
    'hadithText': hadithText,
    'hadithSource': hadithSource,
    'fontFamily': fontFamily,
    'locale': locale,
    'isQuranEnabled': isQuranEnabled,
    'quranReciterName': quranReciterName,
    'quranReciterServerUrl': quranReciterServerUrl,
    'favoriteReciterServerUrls': jsonEncode(favoriteReciterServerUrls),
    'selectedCountry': selectedCountry,
    'selectedCity': selectedCity,
    'selectedLatitude': selectedLatitude,
    'selectedLongitude': selectedLongitude,
    'calculationMethod': calculationMethod,
    'madhab': madhab,
    'isCalculatedLocation': isCalculatedLocation,
    'selectedTimeZoneId': selectedTimeZoneId,
    'utcOffsetHours': utcOffsetHours,
    'layoutStyle': layoutStyle,
    'adhanSound': adhanSound,
    'isAnalogClock': isAnalogClock,
    'isAdhkarEnabled': isAdhkarEnabled,
    'prayerNotificationEnabled': jsonEncode(prayerNotificationEnabled),
    'preAdhanReminderEnabled': jsonEncode(preAdhanReminderEnabled),
    'preAdhanReminderMinutes': preAdhanReminderMinutes,
    'iqamaNotificationEnabled': jsonEncode(iqamaNotificationEnabled),
    'preIqamaReminderEnabled': jsonEncode(preIqamaReminderEnabled),
    'preIqamaReminderMinutes': preIqamaReminderMinutes,
    'isMorningAdhkarNotificationEnabled': isMorningAdhkarNotificationEnabled,
    'isEveningAdhkarNotificationEnabled': isEveningAdhkarNotificationEnabled,
    'morningAdhkarMinuteOfDay': morningAdhkarMinuteOfDay,
    'eveningAdhkarMinuteOfDay': eveningAdhkarMinuteOfDay,
    'isNotificationOnboardingDone': isNotificationOnboardingDone,
    'customAdhans': jsonEncode(customAdhans.map((c) => c.toJson()).toList()),
    'quranPlaybackMode': quranPlaybackMode.name,
    'selectedSurahNumber': selectedSurahNumber,
    'surahPlaylist': jsonEncode(surahPlaylist),
    'surahRepeatCount': surahRepeatCount,
    'playlistCycleCount': playlistCycleCount,
    'continuousStartMode': continuousStartMode.name,
    'lastPlayedSurah': lastPlayedSurah,
  };
}


AppSettings appSettingsFromMap(Map<String, dynamic> map) {
  final customAdhans = decodeCustomAdhans(map['customAdhans']);
  return AppSettings(
    themeColorKey: map['themeColorKey'] as String? ?? 'gold',
    use24HourFormat: map['use24HourFormat'] as bool? ?? false,
    adhanMode: decodePrayerSoundMode(map['adhanMode'], legacyBool: map['playAdhan']),
    iqamaMode: decodePrayerSoundMode(map['iqamaMode'], legacyBool: map['playIqama']),
    isMosqueMode: map['isMosqueMode'] as bool? ?? false,
    isDarkMode: map['isDarkMode'] as bool? ?? false,
    iqamaDelays: decodeIntMap(map['iqamaDelays'], const {
      'fajr': 20,
      'dhuhr': 10,
      'asr': 10,
      'maghrib': 5,
      'isha': 15,
    }),
    adhanOffsets: decodeIntMap(map['adhanOffsets'], const {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    }),
    prayerNotificationEnabled: decodeBoolMap(
      map['prayerNotificationEnabled'],
      defaultBoolMapTrue,
    ),
    preAdhanReminderEnabled: decodeBoolMap(
      map['preAdhanReminderEnabled'],
      defaultBoolMapFalse,
    ),
    iqamaNotificationEnabled: decodeBoolMap(
      map['iqamaNotificationEnabled'],
      defaultBoolMapFalse,
    ),
    preIqamaReminderEnabled: decodeBoolMap(
      map['preIqamaReminderEnabled'],
      defaultBoolMapFalse,
    ),
    hadithText:
        map['hadithText'] as String? ??
        '"Whoever fasts Ramadan then follows it with six days of Shawwal, it is as if he fasted the whole year."',
    hadithSource: map['hadithSource'] as String? ?? 'Sahih Muslim',
    fontFamily:
        const ['Cairo', 'Kufi', 'Beiruti', 'Rubik'].contains(map['fontFamily'])
        ? map['fontFamily'] as String
        : 'Rubik',
    locale: const ['ar', 'en'].contains(map['locale'])
        ? map['locale'] as String
        : 'ar',
    isQuranEnabled: map['isQuranEnabled'] as bool? ?? false,
    quranReciterName: map['quranReciterName'] as String? ?? '',
    quranReciterServerUrl: validatedQuranUrl(
      map['quranReciterServerUrl'] as String? ?? '',
    ),
    favoriteReciterServerUrls:
        decodeStringList(map['favoriteReciterServerUrls']),
    selectedCountry: map['selectedCountry'] as String? ?? 'uae',
    selectedCity: map['selectedCity'] as String? ?? 'Dubai',
    selectedLatitude: map['selectedLatitude'] as double?,
    selectedLongitude: map['selectedLongitude'] as double?,
    calculationMethod:
        map['calculationMethod'] as String? ?? 'muslim_world_league',
    madhab: const ['shafi', 'hanafi'].contains(map['madhab'])
        ? map['madhab'] as String
        : 'shafi',
    isCalculatedLocation: map['isCalculatedLocation'] as bool? ?? false,
    selectedTimeZoneId: map['selectedTimeZoneId'] as String?,
    utcOffsetHours: (map['utcOffsetHours'] as num?)?.toDouble(),
    layoutStyle: const ['classic', 'modern'].contains(map['layoutStyle'])
        ? map['layoutStyle'] as String
        : 'modern',
    adhanSound: validatedAdhanSound(map['adhanSound'] as String?, customAdhans),
    isAnalogClock: map['isAnalogClock'] as bool? ?? false,
    isAdhkarEnabled: map['isAdhkarEnabled'] as bool? ?? true,
    preAdhanReminderMinutes: map['preAdhanReminderMinutes'] as int? ?? 15,
    preIqamaReminderMinutes: map['preIqamaReminderMinutes'] as int? ?? 5,
    isMorningAdhkarNotificationEnabled:
        map['isMorningAdhkarNotificationEnabled'] as bool? ?? false,
    isEveningAdhkarNotificationEnabled:
        map['isEveningAdhkarNotificationEnabled'] as bool? ?? false,
    morningAdhkarMinuteOfDay:
        (map['morningAdhkarMinuteOfDay'] as num?)?.toInt() ?? 420,
    eveningAdhkarMinuteOfDay:
        (map['eveningAdhkarMinuteOfDay'] as num?)?.toInt() ?? 1020,
    isNotificationOnboardingDone:
        map['isNotificationOnboardingDone'] as bool? ?? false,
    customAdhans: customAdhans,
    quranPlaybackMode:
        decodePlaybackMode(map['quranPlaybackMode'], map['surahRepeatMode']),
    selectedSurahNumber: (map['selectedSurahNumber'] as num?)?.toInt(),
    surahPlaylist: decodeSurahPlaylist(map['surahPlaylist']),
    surahRepeatCount: (map['surahRepeatCount'] as num?)?.toInt() ??
        legacyRepeatCountFor(map['surahRepeatMode'], 1),
    playlistCycleCount: (map['playlistCycleCount'] as num?)?.toInt() ?? 1,
    continuousStartMode: decodeContinuousStartMode(map['continuousStartMode']),
    lastPlayedSurah: ((map['lastPlayedSurah'] as num?)?.toInt() ?? 1)
        .clamp(1, 114),
  );
}
