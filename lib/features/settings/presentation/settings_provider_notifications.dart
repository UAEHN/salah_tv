part of 'settings_provider.dart';

extension SettingsProviderNotifications on SettingsProvider {
  Future<void> updatePreAdhanReminderMinutes(int min) =>
      _update(_settings.copyWith(preAdhanReminderMinutes: min));

  Future<void> updatePreIqamaReminderMinutes(int min) =>
      _update(_settings.copyWith(preIqamaReminderMinutes: min));

  Future<void> updatePrayerNotificationEnabled(String key, bool value) =>
      _updateBoolMap(
        key,
        value,
        _settings.prayerNotificationEnabled,
        (map) => _settings.copyWith(prayerNotificationEnabled: map),
      );

  Future<void> updatePreAdhanReminderEnabled(String key, bool value) =>
      _updateBoolMap(
        key,
        value,
        _settings.preAdhanReminderEnabled,
        (map) => _settings.copyWith(preAdhanReminderEnabled: map),
      );

  Future<void> updateIqamaNotificationEnabled(String key, bool value) =>
      _updateBoolMap(
        key,
        value,
        _settings.iqamaNotificationEnabled,
        (map) => _settings.copyWith(iqamaNotificationEnabled: map),
      );

  Future<void> updatePreIqamaReminderEnabled(String key, bool value) =>
      _updateBoolMap(
        key,
        value,
        _settings.preIqamaReminderEnabled,
        (map) => _settings.copyWith(preIqamaReminderEnabled: map),
      );

  Future<void> _updateBoolMap(
    String key,
    bool value,
    Map<String, bool> current,
    AppSettings Function(Map<String, bool>) applyCopy,
  ) {
    final map = Map<String, bool>.from(current);
    map[key] = value;
    return _update(applyCopy(map));
  }
}
