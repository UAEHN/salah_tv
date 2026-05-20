import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../firebase_options.dart';
import '../app_config.dart';

/// Initializes Firebase for both TV and mobile platforms, and primes
/// Remote Config so version-gating values are available before
/// [CheckForUpdateUseCase] is called.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _primeRemoteConfig();
}

Future<void> _primeRemoteConfig() async {
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: AppConfig.rcFetchTimeout,
        // TEMP TESTING: force fresh fetch every launch in release too. Revert
        // to `kDebugMode ? Duration.zero : AppConfig.rcMinFetchInterval` before
        // publishing — Firebase rate-limits aggressive fetches in production.
        minimumFetchInterval: Duration.zero,
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
