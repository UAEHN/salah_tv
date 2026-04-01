import 'dart:convert';
import 'app_settings.dart';

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
  };
}

String _validatedQuranUrl(String url) {
  if (url.isEmpty) return '';
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      !uri.host.endsWith('mp3quran.net')) {
    return '';
  }
  return url;
}

Map<String, bool> _decodeBoolMap(dynamic raw, Map<String, bool> fallback) {
  if (raw == null) return fallback;
  try {
    final decoded = jsonDecode(raw as String) as Map;
    return decoded.map((k, v) => MapEntry(k.toString(), v as bool));
  } on Object {
    // Malformed stored JSON — return safe default.
    return fallback;
  }
}

Map<String, int> _decodeIntMap(dynamic raw, Map<String, int> fallback) {
  if (raw == null) return fallback;
  try {
    final decoded = jsonDecode(raw as String) as Map;
    return decoded.map((k, v) => MapEntry(k.toString(), v as int));
  } on Object {
    // Malformed stored JSON — return safe default.
    return fallback;
  }
}

const _defaultBoolMapTrue = {
  'fajr': true,
  'dhuhr': true,
  'asr': true,
  'maghrib': true,
  'isha': true,
};
const _defaultBoolMapFalse = {
  'fajr': false,
  'dhuhr': false,
  'asr': false,
  'maghrib': false,
  'isha': false,
};

AppSettings appSettingsFromMap(Map<String, dynamic> map) {
  return AppSettings(
    themeColorKey: map['themeColorKey'] as String? ?? 'green',
    use24HourFormat: map['use24HourFormat'] as bool? ?? false,
    playAdhan: map['playAdhan'] as bool? ?? true,
    isDarkMode: map['isDarkMode'] as bool? ?? false,
    iqamaDelays: _decodeIntMap(map['iqamaDelays'], const {
      'fajr': 20,
      'dhuhr': 10,
      'asr': 10,
      'maghrib': 5,
      'isha': 15,
    }),
    adhanOffsets: _decodeIntMap(map['adhanOffsets'], const {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    }),
    prayerNotificationEnabled: _decodeBoolMap(
      map['prayerNotificationEnabled'],
      _defaultBoolMapTrue,
    ),
    preAdhanReminderEnabled: _decodeBoolMap(
      map['preAdhanReminderEnabled'],
      _defaultBoolMapFalse,
    ),
    iqamaNotificationEnabled: _decodeBoolMap(
      map['iqamaNotificationEnabled'],
      _defaultBoolMapFalse,
    ),
    preIqamaReminderEnabled: _decodeBoolMap(
      map['preIqamaReminderEnabled'],
      _defaultBoolMapFalse,
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
    quranReciterServerUrl: _validatedQuranUrl(
      map['quranReciterServerUrl'] as String? ?? '',
    ),
    selectedCountry: map['selectedCountry'] as String? ?? 'UAE',
    selectedCity: map['selectedCity'] as String? ?? 'Dubai',
    selectedLatitude: map['selectedLatitude'] as double?,
    selectedLongitude: map['selectedLongitude'] as double?,
    calculationMethod:
        map['calculationMethod'] as String? ?? 'muslim_world_league',
    madhab: const ['shafi', 'hanafi'].contains(map['madhab'])
        ? map['madhab'] as String
        : 'shafi',
    isCalculatedLocation: map['isCalculatedLocation'] as bool? ?? false,
    utcOffsetHours: (map['utcOffsetHours'] as num?)?.toDouble(),
    layoutStyle: const ['classic', 'modern'].contains(map['layoutStyle'])
        ? map['layoutStyle'] as String
        : 'modern',
    adhanSound: const ['default', 'adhan2'].contains(map['adhanSound'])
        ? map['adhanSound'] as String
        : 'default',
    isAnalogClock: map['isAnalogClock'] as bool? ?? false,
    isAdhkarEnabled: map['isAdhkarEnabled'] as bool? ?? true,
    preAdhanReminderMinutes: map['preAdhanReminderMinutes'] as int? ?? 15,
    preIqamaReminderMinutes: map['preIqamaReminderMinutes'] as int? ?? 5,
  );
}
