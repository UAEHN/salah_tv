part of 'settings_provider.dart';

extension SettingsProviderQuran on SettingsProvider {
  Future<void> updateIsQuranEnabled(bool value) =>
      _update(_settings.copyWith(isQuranEnabled: value));

  Future<void> updateQuranReciter(String name, String serverUrl) => _update(
    _settings.copyWith(
      quranReciterName: name,
      quranReciterServerUrl: serverUrl,
    ),
  );
}
