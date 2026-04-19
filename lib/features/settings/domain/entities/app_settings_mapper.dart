import 'dart:convert';

import 'app_settings.dart';
import 'app_settings_decoders.dart';

/// Serialization helpers for [AppSettings] — kept separate to stay within
/// the 150-line file limit while still living in the same domain/entities layer.
extension AppSettingsMapper on AppSettings {
  Map<String, dynamic> toMap() => {
    'themeColorKey': themeColorKey,
    'use24HourFormat': use24HourFormat,
    'playAdhan': playAdhan,
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
    'customAdhans': jsonEncode(customAdhans.map((c) => c.toJson()).toList()),
  };
}

AppSettings appSettingsFromMap(Map<String, dynamic> map) {
  final customAdhans = decodeCustomAdhans(map['customAdhans']);
  return AppSettings(
    themeColorKey: map['themeColorKey'] as String? ?? 'green',
    use24HourFormat: map['use24HourFormat'] as bool? ?? false,
    playAdhan: map['playAdhan'] as bool? ?? true,
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
        : 'Kufi',
    locale: const ['ar', 'en'].contains(map['locale'])
        ? map['locale'] as String
        : 'ar',
    isQuranEnabled: map['isQuranEnabled'] as bool? ?? false,
    quranReciterName: map['quranReciterName'] as String? ?? '',
    quranReciterServerUrl: validatedQuranUrl(
      map['quranReciterServerUrl'] as String? ?? '',
    ),
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
    customAdhans: customAdhans,
  );
}
