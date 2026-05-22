part of 'settings_provider.dart';

extension SettingsProviderAppearance on SettingsProvider {
  Future<void> addCustomAdhan(CustomAdhan adhan) {
    final next = [..._settings.customAdhans, adhan];
    return _update(_settings.copyWith(customAdhans: next));
  }

  Future<void> removeCustomAdhan(String id) {
    final removed = _settings.customAdhans.where((c) => c.id == id).firstOrNull;
    final next = _settings.customAdhans.where((c) => c.id != id).toList();
    final resetSound =
        removed != null && _settings.adhanSound == removed.settingsKey
        ? 'default'
        : _settings.adhanSound;
    return _update(
      _settings.copyWith(customAdhans: next, adhanSound: resetSound),
    );
  }

  Future<void> renameCustomAdhan(String id, String newLabel) {
    final trimmed = newLabel.trim();
    if (trimmed.isEmpty) return Future.value();
    final next = _settings.customAdhans
        .map((c) => c.id == id ? c.copyWith(label: trimmed) : c)
        .toList();
    return _update(_settings.copyWith(customAdhans: next));
  }

  Future<void> updateTheme(String colorKey) =>
      _update(_settings.copyWith(themeColorKey: colorKey));

  Future<void> updateAdhanMode(PrayerSoundMode mode) =>
      _update(_settings.copyWith(adhanMode: mode));

  Future<void> updateIqamaMode(PrayerSoundMode mode) =>
      _update(_settings.copyWith(iqamaMode: mode));

  Future<void> updateIsMosqueMode(bool value) =>
      _update(_settings.copyWith(isMosqueMode: value));

  Future<void> updateTimeFormat(bool use24h) =>
      _update(_settings.copyWith(use24HourFormat: use24h));

  Future<void> updateDarkMode(bool value) =>
      _update(_settings.copyWith(isDarkMode: value));

  /// Updates the brightness mode. Accepts `'system' | 'light' | 'dark'`.
  /// When set to `'light'` or `'dark'`, [isDarkMode] is kept in sync so
  /// non-context-aware consumers stay correct.
  Future<void> updateThemeMode(String mode) {
    if (mode == 'light') {
      return _update(_settings.copyWith(themeMode: 'light', isDarkMode: false));
    }
    if (mode == 'dark') {
      return _update(_settings.copyWith(themeMode: 'dark', isDarkMode: true));
    }
    return _update(_settings.copyWith(themeMode: 'system'));
  }

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

  Future<void> updateMorningAdhkarNotification(bool value) =>
      _update(_settings.copyWith(isMorningAdhkarNotificationEnabled: value));

  Future<void> updateEveningAdhkarNotification(bool value) =>
      _update(_settings.copyWith(isEveningAdhkarNotificationEnabled: value));

  Future<void> updateMorningAdhkarMinuteOfDay(int minuteOfDay) =>
      _update(_settings.copyWith(morningAdhkarMinuteOfDay: minuteOfDay));

  Future<void> updateEveningAdhkarMinuteOfDay(int minuteOfDay) =>
      _update(_settings.copyWith(eveningAdhkarMinuteOfDay: minuteOfDay));
}
