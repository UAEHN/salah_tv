import 'city_translations.dart';
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
  final platformConfig = await bootstrapPlatform();
  final settingsRepo = registerSettingsRepository();
  final settings = await loadInitialSettings(settingsRepo);
  await registerPrayerServices(settings, platformConfig);
  await initializeFirebase();
  await registerFeatureServices(platformConfig);

  return settings;
}
