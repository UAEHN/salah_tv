/// Port for analytics event logging.
/// Implementation lives in `data/firebase_analytics_service.dart`.
abstract interface class IAnalyticsService {
  /// One-time setup; sets user properties like platform type.
  Future<void> initialize({required bool isTV});

  /// Returns a `NavigatorObserver` for automatic screen tracking.
  /// Typed as `dynamic` to keep the domain layer free of Flutter imports.
  dynamic get navigatorObserver;

  // ── Screen ──────────────────────────────────────────────────────
  void logScreenView(String screenName);

  // ── Prayer cycle ────────────────────────────────────────────────
  void logAdhanStarted(String prayerKey);
  void logIqamaStarted(String prayerKey);
  void logQuranStreamToggled({required bool isPlaying});

  // ── Settings ────────────────────────────────────────────────────
  void logSettingsChanged(String settingKey, String value);
  void logCityChanged(String country, String city);

  // ── Feature usage ───────────────────────────────────────────────
  void logTasbihCompleted(String presetName, int target);
  void logFeedbackSubmitted(String feedbackType);
  void logOnboardingCompleted(String country, String city);
}
