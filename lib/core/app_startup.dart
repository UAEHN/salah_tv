import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'city_translations.dart';
import '../features/adhkar/data/adhkar_audio_service.dart';
import '../features/adhkar/data/adhkar_json_repository.dart';
import '../features/adhkar/data/adhkar_text_repository.dart';
import '../features/adhkar/domain/i_adhkar_audio_port.dart';
import '../features/adhkar/domain/i_adhkar_state_repository.dart';
import '../features/adhkar/domain/i_adhkar_text_repository.dart';
import '../features/audio/data/audio_service.dart';
import '../features/audio/data/noop_prayer_audio_port.dart';
import '../features/audio/domain/i_audio_repository.dart';
import '../features/prayer/data/adhan_calculation_source.dart';
import '../features/prayer/data/calculated_prayer_repository.dart';
import '../features/prayer/data/composite_prayer_repository.dart';
import '../features/prayer/data/sqlite_prayer_repository.dart';
import '../features/prayer/domain/i_prayer_audio_port.dart';
import '../features/prayer/domain/i_prayer_times_repository.dart';
import '../features/settings/data/world_city_json_repository.dart';
import '../features/settings/domain/i_world_city_repository.dart';
import '../features/quran/data/quran_api_service.dart';
import '../features/quran/domain/i_quran_api_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/notifications/data/prayer_notification_service.dart';
import '../features/notifications/domain/i_prayer_notification_port.dart';
import '../features/qibla/data/qibla_repository.dart';
import '../features/qibla/domain/i_qibla_repository.dart';
import '../features/settings/data/gps_location_detector.dart';
import '../features/settings/domain/i_location_detector.dart';
import '../features/settings/domain/i_settings_repository.dart';
import '../features/tasbih/data/tasbih_repository.dart';
import '../features/tasbih/domain/i_tasbih_repository.dart';
import '../features/settings/domain/usecases/load_settings_usecase.dart';
import '../injection.dart';
import 'platform_config.dart';

/// Composition root: initialises all services and registers them in get_it.
/// Returns the loaded [AppSettings] so [main] can pass it to the widget tree.
Future<AppSettings> initDependencies() async {
  // Register app_update services (Dio, UpdateBloc, etc.) via injectable
  configureDependencies();

  // ── Load bundled data assets ──────────────────────────────────────────────
  await loadCityTranslations();

  // ── Detect platform first — kIsTV getter depends on this ──────────────────
  final platformConfig = PlatformConfig();
  await platformConfig.detect();
  getIt.registerSingleton<PlatformConfig>(platformConfig);

  // Keep screen on permanently — TV display app
  await WakelockPlus.enable();

  if (platformConfig.isTV) {
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else {
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }

  // ── Register core services in get_it ──────────────────────────────────────
  final settingsRepo = SettingsRepository();
  getIt.registerSingleton<ISettingsRepository>(settingsRepo);

  final AppSettings settings =
      (await LoadSettingsUseCase(settingsRepo).call()).fold(
        (_) => const AppSettings(),
        (s) => s,
      );

  // Prayer repos: composite routes between SQLite (DB countries) and
  // calculated (adhan_dart, worldwide) based on isCalculatedLocation.
  final sqliteRepo = SqlitePrayerRepository();
  final calcRepo = CalculatedPrayerRepository(AdhanCalculationSource());
  final compositeRepo = CompositePrayerRepository(sqliteRepo, calcRepo);

  if (settings.isCalculatedLocation &&
      settings.selectedLatitude != null &&
      settings.selectedLongitude != null) {
    // Worldwide location — init SQLite anyway for possible mode switch.
    await sqliteRepo.initialize('uae');
    calcRepo.configureCalculatedMode(
      settings.selectedLatitude!,
      settings.selectedLongitude!,
      settings.calculationMethod,
      madhabKey: settings.madhab,
      cityLabel: settings.selectedCity,
      utcOffsetHours: settings.utcOffsetHours,
    );
    compositeRepo.setMode(isCalculated: true);
  } else {
    await sqliteRepo.initialize(settings.selectedCountry);
    compositeRepo.setMode(isCalculated: false);
  }
  getIt.registerSingleton<IPrayerTimesRepository>(compositeRepo);

  final audioService = AudioService();
  getIt.registerSingleton<IAudioRepository>(audioService);
  // Mobile: prayer-cycle audio (adhan/dua/iqama) is silent — notifications carry the sound.
  getIt.registerSingleton<IPrayerAudioPort>(
    platformConfig.isTV ? audioService : NoOpPrayerAudioPort(),
  );

  final adhkarRepo = AdhkarJsonRepository();
  await adhkarRepo.initialize();
  getIt.registerSingleton<AdhkarJsonRepository>(adhkarRepo);
  getIt.registerSingleton<IAdhkarStateRepository>(adhkarRepo);
  getIt.registerSingleton<IAdhkarAudioPort>(AdhkarAudioService());

  getIt.registerLazySingleton<IQuranApiRepository>(
    () => QuranApiService(getIt<Dio>()),
  );

  // Qibla: lazy — only instantiated when user opens the Qibla screen
  getIt.registerLazySingleton<IQiblaRepository>(() => QiblaRepository());

  // Adhkar text reader: mobile only — TV uses audio-based adhkar sessions
  if (!platformConfig.isTV) {
    final adhkarTextRepo = AdhkarTextRepository();
    await adhkarTextRepo.initialize();
    getIt.registerSingleton<IAdhkarTextRepository>(adhkarTextRepo);
  }

  // Prayer notifications: mobile only — TV app is always running in foreground
  if (!platformConfig.isTV) {
    final notifService = PrayerNotificationService();
    await notifService.initialize();
    getIt.registerSingleton<IPrayerNotificationPort>(notifService);

    // Location detection: lazy — only used when user taps detect or first launch
    getIt.registerLazySingleton<ILocationDetector>(
      () => GpsLocationDetector(),
    );

    // World cities catalogue: lazy — only loaded when user opens location picker
    getIt.registerLazySingleton<IWorldCityRepository>(
      () => WorldCityJsonRepository(),
    );

    // Tasbih counter — mobile only, no async init needed
    getIt.registerLazySingleton<ITasbihRepository>(() => TasbihRepository());
  }

  return settings;
}
