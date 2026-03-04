import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo;
  AppSettings _settings;

  SettingsProvider(this._repo, this._settings);

  AppSettings get settings => _settings;

  Future<void> updateTheme(String colorKey) async {
    _settings = _settings.copyWith(themeColorKey: colorKey);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updatePlayAdhan(bool value) async {
    _settings = _settings.copyWith(playAdhan: value);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateTimeFormat(bool use24h) async {
    _settings = _settings.copyWith(use24HourFormat: use24h);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateIqamaDelay(String prayerKey, int minutes) async {
    final newDelays = Map<String, int>.from(_settings.iqamaDelays);
    newDelays[prayerKey] = minutes.clamp(0, 60);
    _settings = _settings.copyWith(iqamaDelays: newDelays);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateAdhanOffset(String prayerKey, int minutes) async {
    final newOffsets = Map<String, int>.from(_settings.adhanOffsets);
    newOffsets[prayerKey] = minutes.clamp(-30, 30);
    _settings = _settings.copyWith(adhanOffsets: newOffsets);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateCsvPath(String? path) async {
    _settings = _settings.copyWith(
      csvFilePath: path,
      clearCsvPath: path == null,
    );
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateHadithText(String text) async {
    _settings = _settings.copyWith(hadithText: text);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateHadithSource(String source) async {
    _settings = _settings.copyWith(hadithSource: source);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateFontFamily(String fontFamily) async {
    _settings = _settings.copyWith(fontFamily: fontFamily);
    await _repo.save(_settings);
    notifyListeners();
  }

  // ── Quran settings ──────────────────────────────────────────────────────

  Future<void> updateIsQuranEnabled(bool value) async {
    _settings = _settings.copyWith(isQuranEnabled: value);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> updateQuranReciter(String name, String serverUrl) async {
    _settings = _settings.copyWith(
      quranReciterName: name,
      quranReciterServerUrl: serverUrl,
    );
    await _repo.save(_settings);
    notifyListeners();
  }
}
