part of 'settings_provider.dart';

extension SettingsProviderAppearance on SettingsProvider {
  Future<void> updateTheme(String colorKey) =>
      _update(_settings.copyWith(themeColorKey: colorKey));

  Future<void> updatePlayAdhan(bool value) =>
      _update(_settings.copyWith(playAdhan: value));

  Future<void> updateTimeFormat(bool use24h) =>
      _update(_settings.copyWith(use24HourFormat: use24h));

  Future<void> updateDarkMode(bool value) =>
      _update(_settings.copyWith(isDarkMode: value));

  Future<void> updateFontFamily(String fontFamily) =>
      _update(_settings.copyWith(fontFamily: fontFamily));

  Future<void> updateLocale(String locale) =>
      _update(_settings.copyWith(locale: locale));

  Future<void> updateHadithText(String text) =>
      _update(_settings.copyWith(hadithText: text));

  Future<void> updateHadithSource(String source) =>
      _update(_settings.copyWith(hadithSource: source));

  Future<void> updateLayoutStyle(String style) =>
      _update(_settings.copyWith(layoutStyle: style));

  Future<void> updateAdhanSound(String key) =>
      _update(_settings.copyWith(adhanSound: key));

  Future<void> updateClockStyle({required bool isAnalog}) =>
      _update(_settings.copyWith(isAnalogClock: isAnalog));

  Future<void> updateIsAdhkarEnabled(bool value) =>
      _update(_settings.copyWith(isAdhkarEnabled: value));
}
