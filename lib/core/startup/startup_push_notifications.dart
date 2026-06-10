import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

import '../../features/push_notifications/data/firebase_push_notifications_repository.dart';
import '../../features/push_notifications/data/firestore_push_profile_repository.dart';
import '../../features/push_notifications/data/noop_push_notifications_repository.dart';
import '../../features/push_notifications/data/shared_prefs_install_id_provider.dart';
import '../../features/push_notifications/domain/i_install_id_provider.dart';
import '../../features/push_notifications/domain/i_push_notifications_repository.dart';
import '../../features/push_notifications/domain/i_push_profile_repository.dart';
import '../../features/push_notifications/domain/usecases/initialize_push_notifications.dart';
import '../../features/push_notifications/domain/usecases/request_push_permission.dart';
import '../../features/push_notifications/domain/usecases/sync_push_profile.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/i_settings_repository.dart';
import '../../injection.dart';
import '../platform_config.dart';

/// Registers the push-notifications layer in GetIt.
/// Mobile: FCM-backed repo + Firestore profile sync. TV: no-op stub so
/// consumers can resolve [IPushNotificationsRepository] without conditional
/// code paths.
void registerPushNotifications(PlatformConfig platformConfig) {
  // Install-id is cross-platform — both push profiles (mobile) and the
  // heartbeat service (TV) need a stable per-device document key.
  getIt.registerLazySingleton<IInstallIdProvider>(
    () => SharedPrefsInstallIdProvider(),
  );
  if (platformConfig.isTV) {
    getIt.registerLazySingleton<IPushNotificationsRepository>(
      () => const NoOpPushNotificationsRepository(),
    );
  } else {
    getIt.registerLazySingleton<IPushNotificationsRepository>(
      () => FirebasePushNotificationsRepository(),
    );
    getIt.registerLazySingleton<IPushProfileRepository>(
      () => FirestorePushProfileRepository(),
    );
    getIt.registerFactory<SyncPushProfile>(
      () => SyncPushProfile(
        installIdProvider: getIt<IInstallIdProvider>(),
        pushRepo: getIt<IPushNotificationsRepository>(),
        profileRepo: getIt<IPushProfileRepository>(),
      ),
    );
  }
  getIt.registerFactory<InitializePushNotifications>(
    () => InitializePushNotifications(
      repo: getIt<IPushNotificationsRepository>(),
    ),
  );
  getIt.registerFactory<RequestPushPermission>(
    () => RequestPushPermission(repo: getIt<IPushNotificationsRepository>()),
  );
}

/// Mobile-only fire-and-forget primer:
///   1. Refreshes the FCM token + re-subscribes to default topics.
///   2. Pushes the device profile (token + lang + country + tz) to Firestore.
///   3. Subscribes to onTokenRefresh so server-side token stays current.
/// Never throws — push is best-effort and must not block app launch.
Future<void> primePushNotifications(PlatformConfig platformConfig) async {
  if (platformConfig.isTV) return;
  try {
    await getIt<InitializePushNotifications>().call();
    await _syncProfileFromSettings();
    _listenForTokenRefresh();
  } catch (_) {
    // Swallow: missing Play Services / transient FCM / Firestore error
    // must not crash the app on boot.
  }
}

Future<void> _syncProfileFromSettings({String? overrideToken}) async {
  final settingsEither = await getIt<ISettingsRepository>().load();
  final settings = settingsEither.fold((_) => null, (s) => s);
  if (settings == null) return;
  final appVersion = await _readAppVersion();
  await getIt<SyncPushProfile>().call(
    language: settings.locale,
    country: settings.selectedCountry,
    city: settings.selectedCity.isNotEmpty ? settings.selectedCity : null,
    timezone: _resolveTimezone(settings),
    platform: 'android_mobile',
    appVersion: appVersion,
    overrideToken: overrideToken,
  );
}

void _listenForTokenRefresh() {
  final repo = getIt<IPushNotificationsRepository>();
  repo.onTokenRefresh.listen((token) async {
    try {
      await _syncProfileFromSettings(overrideToken: token);
    } catch (_) {
      // ignored — next boot's primer will retry.
    }
  });
}

String _resolveTimezone(AppSettings s) {
  final id = s.selectedTimeZoneId;
  if (id != null && id.isNotEmpty) return id;
  return DateTime.now().timeZoneName;
}

Future<String> _readAppVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  } catch (_) {
    return 'unknown';
  }
}
