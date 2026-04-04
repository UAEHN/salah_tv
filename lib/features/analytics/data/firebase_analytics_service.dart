import 'package:firebase_analytics/firebase_analytics.dart';

import '../domain/i_analytics_service.dart';

class FirebaseAnalyticsService implements IAnalyticsService {
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  @override
  Future<void> initialize({required bool isTV}) async {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    await _analytics.setUserProperty(
      name: 'platform_type',
      value: isTV ? 'tv' : 'mobile',
    );
  }

  @override
  dynamic get navigatorObserver => _observer;

  // ── Screen ──────────────────────────────────────────────────────

  @override
  void logScreenView(String screenName) {
    _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // ── Prayer cycle ────────────────────────────────────────────────

  @override
  void logAdhanStarted(String prayerKey) {
    _analytics.logEvent(
      name: 'adhan_started',
      parameters: {'prayer_key': prayerKey},
    );
  }

  @override
  void logIqamaStarted(String prayerKey) {
    _analytics.logEvent(
      name: 'iqama_started',
      parameters: {'prayer_key': prayerKey},
    );
  }

  @override
  void logQuranStreamToggled({required bool isPlaying}) {
    _analytics.logEvent(
      name: 'quran_stream_toggled',
      parameters: {'is_playing': isPlaying.toString()},
    );
  }

  // ── Settings ────────────────────────────────────────────────────

  @override
  void logSettingsChanged(String settingKey, String value) {
    _analytics.logEvent(
      name: 'settings_changed',
      parameters: {'setting_key': settingKey, 'value': value},
    );
  }

  @override
  void logCityChanged(String country, String city) {
    _analytics.logEvent(
      name: 'city_changed',
      parameters: {'country': country, 'city': city},
    );
  }

  // ── Feature usage ───────────────────────────────────────────────

  @override
  void logTasbihCompleted(String presetName, int target) {
    _analytics.logEvent(
      name: 'tasbih_completed',
      parameters: {'preset_name': presetName, 'target': target},
    );
  }

  @override
  void logFeedbackSubmitted(String feedbackType) {
    _analytics.logEvent(
      name: 'feedback_submitted',
      parameters: {'type': feedbackType},
    );
  }

  @override
  void logOnboardingCompleted(String country, String city) {
    _analytics.logEvent(
      name: 'onboarding_completed',
      parameters: {'country': country, 'city': city},
    );
  }
}
