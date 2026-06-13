import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'city_translations.dart';
import 'health/heartbeat_service.dart';
import 'startup/startup_city_catalog.dart';
import '../features/analytics/domain/i_analytics_service.dart';
import '../features/push_notifications/domain/i_install_id_provider.dart';
import '../features/settings/domain/entities/app_settings.dart';
import 'startup/startup_features.dart';
import 'startup/startup_firebase.dart';
import 'startup/startup_platform.dart';
import 'startup/startup_prayer.dart';
import 'startup/startup_settings.dart';
import '../injection.dart';

/// Composition root: initialises all services and registers them in get_it.
/// Returns the loaded [AppSettings] so [main] can pass it to the widget tree.
Future<AppSettings> initDependencies() async {
  configureDependencies();
  await loadCityTranslations();
  // Merge the cached remote city catalog over the bundled lists (no network).
  // Lets cities published since the last APK appear in the picker immediately.
  await applyCachedCityCatalog();
  final platformConfig = await bootstrapPlatform();
  final settingsRepo = registerSettingsRepository();
  final settings = await loadInitialSettings(settingsRepo);
  // Gate first-launch behaviour: before onboarding commits a city, the prayer
  // data pipeline must not pre-load/download the bundled default city.
  final isFirstLaunch = await settingsRepo.isFirstLaunch();
  await initializeFirebase();
  await initializeAnalytics(isTV: platformConfig.isTV);
  await registerPrayerServices(
    settings,
    platformConfig,
    isFirstLaunch: isFirstLaunch,
  );
  await registerFeatureServices(platformConfig);
  await _attachAnalyticsDeviceId();

  // Fire-and-forget: refresh the remote city catalog for next launch (and this
  // session if a picker opens later). Both platforms — never blocks boot.
  unawaited(primeCityCatalog());

  // Heartbeat: always-on for TV (operational telemetry).
  // In debug builds we also enable it on mobile / phone emulators so the
  // dashboard can verify the wiring end-to-end during local testing.
  // Release builds on mobile stay quiet — 1k+ mobile users every 5 min
  // would blow past Firestore Spark plan free quota.
  if (platformConfig.isTV || kDebugMode) {
    await _startHeartbeat(platformConfig.isTV);
  }

  return settings;
}

/// Resolves the stable install id (same value the heartbeat uses) and tags
/// analytics events with it as a `device_id` user property. Runs after
/// feature registration so [IInstallIdProvider] is available. Best-effort —
/// a failure here must never block startup.
Future<void> _attachAnalyticsDeviceId() async {
  try {
    final id = await getIt<IInstallIdProvider>().getOrCreate();
    await id.fold(
      (_) async {},
      (value) => getIt<IAnalyticsService>().setDeviceId(value),
    );
  } catch (_) {}
}

Future<void> _startHeartbeat(bool isTV) async {
  final service = HeartbeatService(
    getIt<IInstallIdProvider>(),
    FirebaseFirestore.instance,
    platform: isTV ? 'tv' : 'mobile',
  );
  getIt.registerSingleton<HeartbeatService>(service);
  // Fire-and-forget — heartbeat must never block startup.
  unawaited(service.start());
}
