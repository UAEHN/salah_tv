import '../../../settings/domain/entities/app_settings.dart';

/// Maps the user's current [AppSettings] into a flat string-only diagnostic
/// snapshot. Lives in the feedback presentation layer because the feedback
/// domain must not import another feature's domain entities — settings is
/// already accessible from feedback presentation via `SettingsProvider`.
Map<String, String> buildFeedbackSettingsSnapshot(AppSettings s) {
  return {
    'selectedCity': s.selectedCity,
    'selectedCountry': s.selectedCountry,
    'isCalculatedLocation': s.isCalculatedLocation.toString(),
    'selectedTimeZoneId': s.selectedTimeZoneId ?? '-',
    'utcOffsetHours': s.utcOffsetHours?.toString() ?? '-',
    'selectedLatitude': s.selectedLatitude?.toString() ?? '-',
    'selectedLongitude': s.selectedLongitude?.toString() ?? '-',
    'calculationMethod': s.calculationMethod,
    'madhab': s.madhab,
    'layoutStyle': s.layoutStyle,
    'adhanMode': s.adhanMode.name,
    'iqamaMode': s.iqamaMode.name,
    'isMosqueMode': s.isMosqueMode.toString(),
    'adhanSound': s.adhanSound,
    'isQuranEnabled': s.isQuranEnabled.toString(),
    'locale': s.locale,
    'themeColorKey': s.themeColorKey,
    'isDarkMode': s.isDarkMode.toString(),
  };
}
