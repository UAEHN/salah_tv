import 'package:flutter/foundation.dart';
import '../domain/entities/app_settings.dart';
import '../../quran/domain/entities/quran_reciter.dart';
import '../domain/i_settings_repository.dart';
import '../../quran/domain/i_quran_api_repository.dart';
import '../domain/usecases/save_settings_usecase.dart';

class SettingsProvider extends ChangeNotifier {
  final SaveSettingsUseCase _save;
  final IQuranApiRepository _quranApiRepo;
  AppSettings _settings;

  SettingsProvider(ISettingsRepository repo, this._quranApiRepo, this._settings)
    : _save = SaveSettingsUseCase(repo);

  AppSettings get settings => _settings;

  Future<void> _update(AppSettings s) async {
    _settings = s;
    await _save(_settings);
    notifyListeners();
  }

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

  Future<void> updateSelectedCountry(String country) =>
      _update(_settings.copyWith(selectedCountry: country));

  Future<void> updateSelectedCity(String city) =>
      _update(_settings.copyWith(selectedCity: city));

  Future<void> updateLocation(String country, String city) =>
      _update(_settings.copyWith(selectedCountry: country, selectedCity: city));

  // ── Quran ─────────────────────────────────────────────────────────────

  Future<void> updateIsQuranEnabled(bool value) =>
      _update(_settings.copyWith(isQuranEnabled: value));

  Future<void> updateQuranReciter(String name, String serverUrl) =>
      _update(_settings.copyWith(
        quranReciterName: name, quranReciterServerUrl: serverUrl,
      ));

  Future<List<QuranApiReciter>> fetchReciters() async {
    final result = await _quranApiRepo.fetchReciters();
    return result.fold((_) => [], (list) => list);
  }

  // ── Prayer time offsets ───────────────────────────────────────────────

  Future<void> updateIqamaDelay(String prayerKey, int minutes) async {
    final m = Map<String, int>.from(_settings.iqamaDelays);
    m[prayerKey] = minutes.clamp(0, 60);
    _update(_settings.copyWith(iqamaDelays: m));
  }

  Future<void> updateAdhanOffset(String prayerKey, int minutes) async {
    final m = Map<String, int>.from(_settings.adhanOffsets);
    m[prayerKey] = minutes.clamp(-30, 30);
    _update(_settings.copyWith(adhanOffsets: m));
  }

  // ── Notification settings (mobile) ────────────────────────────────────

  Future<void> updatePreAdhanReminderMinutes(int min) =>
      _update(_settings.copyWith(preAdhanReminderMinutes: min));

  Future<void> updatePreIqamaReminderMinutes(int min) =>
      _update(_settings.copyWith(preIqamaReminderMinutes: min));

  Future<void> updatePrayerNotificationEnabled(String key, bool v) =>
      _updateBoolMap(key, v, _settings.prayerNotificationEnabled,
          (m) => _settings.copyWith(prayerNotificationEnabled: m));

  Future<void> updatePreAdhanReminderEnabled(String key, bool v) =>
      _updateBoolMap(key, v, _settings.preAdhanReminderEnabled,
          (m) => _settings.copyWith(preAdhanReminderEnabled: m));

  Future<void> updateIqamaNotificationEnabled(String key, bool v) =>
      _updateBoolMap(key, v, _settings.iqamaNotificationEnabled,
          (m) => _settings.copyWith(iqamaNotificationEnabled: m));

  Future<void> updatePreIqamaReminderEnabled(String key, bool v) =>
      _updateBoolMap(key, v, _settings.preIqamaReminderEnabled,
          (m) => _settings.copyWith(preIqamaReminderEnabled: m));

  Future<void> _updateBoolMap(
    String key, bool value, Map<String, bool> current,
    AppSettings Function(Map<String, bool>) applyCopy,
  ) {
    final m = Map<String, bool>.from(current);
    m[key] = value;
    return _update(applyCopy(m));
  }
}
