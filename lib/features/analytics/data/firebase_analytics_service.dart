import '../domain/i_analytics_service.dart';
import 'firebase_analytics_base.dart';
import 'firebase_analytics_cycle_diagnostics_mixin.dart';
import 'firebase_analytics_data_events_mixin.dart';
import 'firebase_analytics_prayer_health_mixin.dart';

class FirebaseAnalyticsService extends FirebaseAnalyticsBase
    with PrayerHealthEventsMixin, DataEventsMixin, CycleDiagnosticsMixin
    implements IAnalyticsService {
  // ── Screen ──────────────────────────────────────────────────────

  @override
  void logScreenView(String screenName) =>
      analytics.logScreenView(screenName: screenName, screenClass: screenName);

  // ── Prayer cycle (existing) ─────────────────────────────────────

  @override
  void logAdhanStarted(String prayerKey) =>
      logEventInternal('adhan_started', {'prayer_key': prayerKey});

  @override
  void logIqamaStarted(String prayerKey) =>
      logEventInternal('iqama_started', {'prayer_key': prayerKey});

  @override
  void logQuranStreamToggled({required bool isPlaying}) => logEventInternal(
    'quran_stream_toggled',
    {'is_playing': isPlaying.toString()},
  );

  // ── Settings ────────────────────────────────────────────────────

  @override
  void logSettingsChanged(String settingKey, String value) => logEventInternal(
    'settings_changed',
    {'setting_key': settingKey, 'value': value},
  );

  @override
  void logCityChanged(String country, String city) =>
      logEventInternal('city_changed', {'country': country, 'city': city});

  // ── Feature usage ───────────────────────────────────────────────

  @override
  void logTasbihCompleted(String presetName, int target) => logEventInternal(
    'tasbih_completed',
    {'preset_name': presetName, 'target': target},
  );

  @override
  void logFeedbackSubmitted(String feedbackType) =>
      logEventInternal('feedback_submitted', {'type': feedbackType});

  @override
  void logOnboardingCompleted(String country, String city) => logEventInternal(
    'onboarding_completed',
    {'country': country, 'city': city},
  );

  // ── Customization ───────────────────────────────────────────────

  @override
  void logThemeChanged(String themeKey) =>
      logEventInternal('theme_changed', {'theme_key': themeKey});

  @override
  void logFontChanged(String fontFamily) =>
      logEventInternal('font_changed', {'font_family': fontFamily});
}
