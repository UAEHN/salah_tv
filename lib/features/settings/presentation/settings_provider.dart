import 'package:flutter/foundation.dart';
import '../../analytics/domain/i_analytics_service.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/app_settings_copy_with.dart';
import '../domain/i_settings_repository.dart';
import '../domain/usecases/save_settings_usecase.dart';

part 'settings_provider_appearance.dart';
part 'settings_provider_location.dart';
part 'settings_provider_quran.dart';
part 'settings_provider_notifications.dart';

class SettingsProvider extends ChangeNotifier {
  final SaveSettingsUseCase _save;
  final IAnalyticsService? _analytics;
  AppSettings _settings;

  SettingsProvider(
    ISettingsRepository repo,
    this._settings, {
    IAnalyticsService? analytics,
  })  : _save = SaveSettingsUseCase(repo),
        _analytics = analytics;

  AppSettings get settings => _settings;

  Future<void> _update(AppSettings s) async {
    final prev = _settings;
    _settings = s;
    notifyListeners();
    final result = await _save(_settings);
    result.fold((failure) {
      debugPrint('[Settings] persist failed: $failure — rolling back');
      _settings = prev;
      notifyListeners();
    }, (_) => _logSettingsDiff(prev, s));
  }

  void _logSettingsDiff(AppSettings prev, AppSettings next) {
    final a = _analytics;
    if (a == null) return;
    if (prev.selectedCity != next.selectedCity ||
        prev.selectedCountry != next.selectedCountry) {
      a.logCityChanged(next.selectedCountry, next.selectedCity);
    }
    if (prev.themeColorKey != next.themeColorKey) {
      a.logSettingsChanged('theme', next.themeColorKey);
    }
    if (prev.layoutStyle != next.layoutStyle) {
      a.logSettingsChanged('layout', next.layoutStyle);
    }
    if (prev.isDarkMode != next.isDarkMode) {
      a.logSettingsChanged('dark_mode', next.isDarkMode.toString());
    }
    if (prev.adhanSound != next.adhanSound) {
      a.logSettingsChanged('adhan_sound', next.adhanSound);
    }
    if (prev.locale != next.locale) {
      a.logSettingsChanged('locale', next.locale);
    }
  }
}
