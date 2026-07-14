part of 'settings_provider.dart';

extension SettingsProviderNotifications on SettingsProvider {
  Future<void> updatePreAdhanReminderMinutes(int min) =>
      _update(_settings.copyWith(preAdhanReminderMinutes: min));

  /// Marks the notification onboarding as complete so the gate in app.dart
  /// stops showing the flow on subsequent launches.
  Future<void> markNotificationOnboardingDone() =>
      _update(_settings.copyWith(isNotificationOnboardingDone: true));

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

  /// Sets the per-prayer pre-adhan reminder sound. [soundKey] is `'silent'`
  /// or a `custom:<fileName>` key referring to an imported sound.
  Future<void> updatePreAdhanReminderSound(String prayerKey, String soundKey) {
    final map = Map<String, String>.from(_settings.preAdhanReminderSound);
    map[prayerKey] = soundKey;
    return _update(_settings.copyWith(preAdhanReminderSound: map));
  }

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
