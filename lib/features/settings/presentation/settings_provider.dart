import 'package:flutter/foundation.dart';
import '../../analytics/domain/i_analytics_service.dart';
import '../../quran/domain/entities/quran_playback_mode.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/app_settings_copy_with.dart';
import '../domain/entities/custom_adhan.dart';
import '../domain/entities/prayer_sound_mode.dart';
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
  }) : _save = SaveSettingsUseCase(repo),
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
    // ── Display & locale (existing) ─────────────────────────────────
    _diffStr(a, 'theme', prev.themeColorKey, next.themeColorKey);
    _diffStr(a, 'layout', prev.layoutStyle, next.layoutStyle);
    _diffBool(a, 'dark_mode', prev.isDarkMode, next.isDarkMode);
    _diffStr(a, 'adhan_sound', prev.adhanSound, next.adhanSound);
    _diffStr(a, 'locale', prev.locale, next.locale);
    // ── Phase 1B.4: prayer-cycle config ─────────────────────────────
    _diffStr(a, 'adhan_mode', prev.adhanMode.name, next.adhanMode.name);
    _diffStr(a, 'iqama_mode', prev.iqamaMode.name, next.iqamaMode.name);
    _diffBool(a, 'mosque_mode', prev.isMosqueMode, next.isMosqueMode);
    _diffStr(a, 'calc_method', prev.calculationMethod, next.calculationMethod);
    _diffStr(a, 'madhab', prev.madhab, next.madhab);
    _diffStr(a, 'high_lat_rule', prev.highLatitudeRule, next.highLatitudeRule);
    _diffInt(
      a,
      'pre_adhan_minutes',
      prev.preAdhanReminderMinutes,
      next.preAdhanReminderMinutes,
    );
    // ── Phase 1B.4: Quran ───────────────────────────────────────────
    _diffStr(
      a,
      'quran_playback_mode',
      prev.quranPlaybackMode.name,
      next.quranPlaybackMode.name,
    );
    _diffStr(a, 'quran_reciter', prev.quranReciterName, next.quranReciterName);
    _diffBool(a, 'quran_enabled', prev.isQuranEnabled, next.isQuranEnabled);
    // ── Phase 1B.4: display extras ──────────────────────────────────
    _diffStr(a, 'theme_mode', prev.themeMode, next.themeMode);
    _diffBool(a, 'use_24h', prev.use24HourFormat, next.use24HourFormat);
    _diffStr(a, 'font', prev.fontFamily, next.fontFamily);
    _diffBool(a, 'analog_clock', prev.isAnalogClock, next.isAnalogClock);
    _diffBool(a, 'adhkar_enabled', prev.isAdhkarEnabled, next.isAdhkarEnabled);
    _diffBool(
      a,
      'after_prayer_adhkar_enabled',
      prev.isAfterPrayerAdhkarEnabled,
      next.isAfterPrayerAdhkarEnabled,
    );
    _diffStr(
      a,
      'timezone',
      prev.selectedTimeZoneId ?? '',
      next.selectedTimeZoneId ?? '',
    );
  }

  static void _diffStr(
    IAnalyticsService a,
    String key,
    String prev,
    String next,
  ) {
    if (prev != next) a.logSettingsChanged(key, next);
  }

  static void _diffBool(IAnalyticsService a, String key, bool prev, bool next) {
    if (prev != next) a.logSettingsChanged(key, next.toString());
  }

  static void _diffInt(IAnalyticsService a, String key, int prev, int next) {
    if (prev != next) a.logSettingsChanged(key, next.toString());
  }
}
