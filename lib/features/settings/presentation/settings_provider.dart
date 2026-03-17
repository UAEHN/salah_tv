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

  SettingsProvider(
    ISettingsRepository repo,
    this._quranApiRepo,
    this._settings,
  ) : _save = SaveSettingsUseCase(repo);

  AppSettings get settings => _settings;

  Future<void> updateTheme(String colorKey) async {
    _settings = _settings.copyWith(themeColorKey: colorKey);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updatePlayAdhan(bool value) async {
    _settings = _settings.copyWith(playAdhan: value);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateTimeFormat(bool use24h) async {
    _settings = _settings.copyWith(use24HourFormat: use24h);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateIqamaDelay(String prayerKey, int minutes) async {
    final newDelays = Map<String, int>.from(_settings.iqamaDelays);
    newDelays[prayerKey] = minutes.clamp(0, 60);
    _settings = _settings.copyWith(iqamaDelays: newDelays);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateAdhanOffset(String prayerKey, int minutes) async {
    final newOffsets = Map<String, int>.from(_settings.adhanOffsets);
    newOffsets[prayerKey] = minutes.clamp(-30, 30);
    _settings = _settings.copyWith(adhanOffsets: newOffsets);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateHadithText(String text) async {
    _settings = _settings.copyWith(hadithText: text);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateHadithSource(String source) async {
    _settings = _settings.copyWith(hadithSource: source);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateFontFamily(String fontFamily) async {
    _settings = _settings.copyWith(fontFamily: fontFamily);
    await _save(_settings);
    notifyListeners();
  }

  // ── Quran settings ──────────────────────────────────────────────────────

  Future<void> updateIsQuranEnabled(bool value) async {
    _settings = _settings.copyWith(isQuranEnabled: value);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateQuranReciter(String name, String serverUrl) async {
    _settings = _settings.copyWith(
      quranReciterName: name,
      quranReciterServerUrl: serverUrl,
    );
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateLayoutStyle(String style) async {
    _settings = _settings.copyWith(layoutStyle: style);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateSelectedCountry(String country) async {
    _settings = _settings.copyWith(selectedCountry: country);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateSelectedCity(String city) async {
    _settings = _settings.copyWith(selectedCity: city);
    await _save(_settings);
    notifyListeners();
  }

  /// Returns reciters list, or empty list on failure.
  Future<List<QuranApiReciter>> fetchReciters() async {
    final result = await _quranApiRepo.fetchReciters();
    return result.fold((_) => [], (list) => list);
  }

  Future<void> updateAdhanSound(String key) async {
    _settings = _settings.copyWith(adhanSound: key);
    await _save(_settings);
    notifyListeners();
  }

  Future<void> updateClockStyle({required bool isAnalog}) async {
    _settings = _settings.copyWith(isAnalogClock: isAnalog);
    await _save(_settings);
    notifyListeners();
  }
}
