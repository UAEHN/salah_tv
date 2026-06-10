import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/data/firebase_analytics_service.dart';
import '../../features/analytics/domain/i_analytics_service.dart';
import '../../firebase_options.dart';
import '../app_config.dart';
import '../../injection.dart';

/// Initializes Firebase for both TV and mobile platforms, and primes
/// Remote Config so version-gating values are available before
/// [CheckForUpdateUseCase] is called.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Crashlytics is silenced in debug builds so local development crashes
  // don't pollute the production crash list.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  await _primeRemoteConfig();
}

/// Builds [FirebaseAnalyticsService] and registers it as [IAnalyticsService].
/// Must run after [initializeFirebase] (Analytics depends on Firebase Core)
/// and before [registerPrayerServices] so the prayer cycle engine and
/// data-layer services can take it via constructor injection.
Future<void> initializeAnalytics({required bool isTV}) async {
  final service = FirebaseAnalyticsService();
  await service.initialize(isTV: isTV);
  getIt.registerSingleton<IAnalyticsService>(service);
}

Future<void> _primeRemoteConfig() async {
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: AppConfig.rcFetchTimeout,
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : AppConfig.rcMinFetchInterval,
      ),
    );
    await rc.setDefaults(<String, Object>{
      AppConfig.rcKeyLatestCode: 0,
      AppConfig.rcKeyMinSupported: 0,
      AppConfig.rcKeyStoreUrl: AppConfig.playStoreUrl,
      AppConfig.rcKeyMessageAr: '',
      AppConfig.rcKeyAnnouncementId: '',
      AppConfig.rcKeyAnnouncementActive: false,
      AppConfig.rcKeyAnnouncementTitleAr: '',
      AppConfig.rcKeyAnnouncementTitleEn: '',
      AppConfig.rcKeyAnnouncementBodyAr: '',
      AppConfig.rcKeyAnnouncementBodyEn: '',
      AppConfig.rcKeyAnnouncementCtaUrl: '',
      AppConfig.rcKeyAnnouncementCtaLabelAr: '',
      AppConfig.rcKeyAnnouncementCtaLabelEn: '',
      AppConfig.rcKeyAnnouncementMinVersionCode: 0,
      AppConfig.rcKeyAnnouncementMaxVersionCode: 0,
      // Eid Takbeerat — feature ships dark; flip `enabled` from console once
      // the implementation is merged and reciter URLs are live.
      AppConfig.rcKeyTakbeeratEnabled: false,
      AppConfig.rcKeyTakbeeratForceHide: false,
      AppConfig.rcKeyTakbeeratForceShow: false,
      AppConfig.rcKeyTakbeeratFitrStartOffset: 1,
      AppConfig.rcKeyTakbeeratFitrEndOffset: 0,
      AppConfig.rcKeyTakbeeratAdhaStartOffset: 2,
      AppConfig.rcKeyTakbeeratAdhaEndOffset: 3,
      AppConfig.rcKeyTakbeeratRecitersJson: '[]',
    });
    // Fail-soft: a flaky TV-box network must never block app boot.
    await rc.fetchAndActivate().timeout(AppConfig.rcFetchTimeout);
  } catch (_) {
    // Defaults remain in place; AppUpdateTrigger will simply see
    // upToDate (latest=0 < currentBuild) and do nothing.
  }
}
