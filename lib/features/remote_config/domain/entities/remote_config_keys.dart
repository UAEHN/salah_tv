import '../../../../core/app_config.dart';

/// Single source of truth for every Firebase Remote Config parameter used
/// in the app, plus the fallback value each key resolves to when Firebase
/// has nothing for it.
///
/// **Why this exists:** previously RC keys lived next to each feature
/// (`AppConfig.rcKey*`, plus per-feature datasources). That made it hard
/// to see "what can I tune from the console without shipping an APK?" at a
/// glance. New keys should be declared here; legacy keys are re-exported
/// from [AppConfig] so the existing call sites keep working unchanged.
///
/// **How to add a key:**
/// 1. Add `static const String myKey = 'my_console_key';` below.
/// 2. Add an entry to [defaults] so reads return a sane value before the
///    first fetch lands.
/// 3. Read it via `getIt<IRemoteConfigRepository>().getXxx(myKey)`.
class RemoteConfigKeys {
  const RemoteConfigKeys._();

  // ─── Legacy keys (re-export only; still defined in AppConfig) ─────────
  // Listed here so the registry is exhaustive — do NOT duplicate the value.
  static const String latestAppVersionCode = AppConfig.rcKeyLatestCode;
  static const String minSupportedVersionCode = AppConfig.rcKeyMinSupported;
  static const String storeUrl = AppConfig.rcKeyStoreUrl;
  static const String updateMessageAr = AppConfig.rcKeyMessageAr;

  static const String announcementId = AppConfig.rcKeyAnnouncementId;
  static const String announcementActive = AppConfig.rcKeyAnnouncementActive;

  static const String takbeeratEnabled = AppConfig.rcKeyTakbeeratEnabled;
  static const String takbeeratForceHide = AppConfig.rcKeyTakbeeratForceHide;
  static const String takbeeratForceShow = AppConfig.rcKeyTakbeeratForceShow;

  // ─── Phase 2 — Mobile feature flags ───────────────────────────────────
  /// Master kill-switches for non-core mobile tabs. `true` keeps the tab
  /// in the bottom navigation (current behaviour); `false` hides it without
  /// requiring an app update. Prayer tab is intentionally not togglable —
  /// it is the core surface of the app.
  static const String featureQiblaEnabled = 'feature_qibla_enabled';
  static const String featureAdhkarEnabled = 'feature_adhkar_enabled';
  static const String featureMushafEnabled = 'feature_mushaf_enabled';

  // Add new keys above this line.

  /// Fallback values returned when Firebase has no value for a key.
  /// Calling `setDefaults` with this map is additive — it merges with the
  /// boot-time defaults registered by `_primeRemoteConfig` rather than
  /// replacing them.
  ///
  /// New flags default to `true` so installing this APK before the Console
  /// values are set keeps the existing behaviour intact.
  static const Map<String, Object> defaults = <String, Object>{
    featureQiblaEnabled: true,
    featureAdhkarEnabled: true,
    featureMushafEnabled: true,
  };
}
