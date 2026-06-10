import 'dart:async';

import '../../features/analytics/domain/i_analytics_service.dart';
import '../../features/audio/data/audio_service.dart';
import '../../features/audio/data/noop_prayer_audio_port.dart';
import '../../features/audio/data/noop_takbeerat_audio_port.dart';
import '../../features/audio/data/takbeerat_audio_service.dart';
import '../../features/audio/domain/i_audio_repository.dart';
import '../../features/prayer/data/adhan_calculation_source.dart';
import '../../features/prayer/data/calculated_prayer_repository.dart';
import '../../features/prayer/data/composite_prayer_repository.dart';
import '../../features/prayer/data/downloaded_prayer_repository.dart';
import '../../features/prayer/data/prayer_cache_db_initializer.dart';
import '../../features/prayer/data/prayer_cache_db_queries.dart';
import '../../features/prayer/data/prayer_cache_db_writer.dart';
import '../../features/prayer/data/prayer_city_downloader.dart';
import '../../features/prayer/domain/cancellation_token.dart';
import '../../features/prayer/domain/i_prayer_audio_port.dart';
import '../../features/prayer/domain/i_takbeerat_audio_port.dart';
import '../../features/prayer/domain/i_prayer_times_repository.dart';
import '../../features/prayer/domain/usecases/check_city_update_use_case.dart';
import '../../features/prayer/domain/usecases/download_city_use_case.dart';
import '../../features/settings/data/android_media_store_publisher.dart';
import '../../features/settings/data/custom_adhan_repository.dart';
import '../../features/settings/data/datasources/custom_adhan_file_datasource.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/i_custom_adhan_repository.dart';
import '../../features/settings/domain/i_notification_sound_publisher.dart';
import '../../injection.dart';
import '../platform_config.dart';

Future<void> registerPrayerServices(
  AppSettings settings,
  PlatformConfig platformConfig, {
  required bool isFirstLaunch,
}) async {
  // ── Open prayer_cache.db ─────────────────────────────────────────────────
  final cacheDb = await PrayerCacheDbInitializer().openOrCreate();

  // ── Build repos ──────────────────────────────────────────────────────────
  final downloadedRepo = DownloadedPrayerRepository(cacheDb);
  final calcRepo = CalculatedPrayerRepository(AdhanCalculationSource());
  final compositeRepo = CompositePrayerRepository(downloadedRepo, calcRepo);

  // ── Build use cases ──────────────────────────────────────────────────────
  final queries = PrayerCacheDbQueries();
  final downloader = PrayerCityDownloader(
    analytics: getIt<IAnalyticsService>(),
  );
  final writer = PrayerCacheDbWriter();
  final downloadUseCase = DownloadCityUseCase(
    cacheDb,
    queries,
    downloader,
    writer,
  );
  final checkUpdateUseCase = CheckCityUpdateUseCase(
    cacheDb,
    queries,
    downloader,
    downloadUseCase,
  );

  // ── Register in DI ───────────────────────────────────────────────────────
  getIt.registerSingleton<CompositePrayerRepository>(compositeRepo);
  getIt.registerSingleton<DownloadCityUseCase>(downloadUseCase);
  getIt.registerSingleton<IPrayerTimesRepository>(compositeRepo);

  // First launch: the city is still the bundled default ('Dubai'), not the
  // user's choice — skip pre-loading/downloading it. Onboarding configures the
  // repo with the chosen city on completion, so the prayer-data pipeline never
  // runs for a city the user never picked.
  // ── Configure initial mode ───────────────────────────────────────────────
  if (!isFirstLaunch) {
    if (_isCalculated(settings)) {
      calcRepo.configureCalculatedMode(
        settings.selectedLatitude!,
        settings.selectedLongitude!,
        settings.calculationMethod,
        madhabKey: settings.madhab,
        highLatitudeRuleKey: settings.highLatitudeRule,
        cityLabel: settings.selectedCity,
        timeZoneId: settings.selectedTimeZoneId,
        utcOffsetHours: settings.utcOffsetHours,
      );
      // compositeRepo defaults to calculated mode
    } else {
      final countryKey = settings.selectedCountry.toLowerCase();
      final isCached = await queries.isCityCached(
        cacheDb,
        countryKey,
        settings.selectedCity,
        DateTime.now().year,
      );
      if (isCached) {
        await downloadedRepo.loadCity(countryKey, settings.selectedCity);
        compositeRepo.configureDatabaseMode();
        // Background hash check — silent on any failure
        unawaited(
          checkUpdateUseCase(
            countryKey: countryKey,
            cityName: settings.selectedCity,
          ),
        );
      } else {
        // City not cached → download now under the splash screen (~14 KB, fast).
        final result = await downloadUseCase(
          countryKey: countryKey,
          cityName: settings.selectedCity,
          cancelToken: CancellationToken(),
        );
        await result.fold(
          (_) async {
            // Download failed — fall back to last successfully cached city if
            // available, so the user sees correct times rather than (0°,0°) garbage.
            final fallback = await queries.getLastCachedCity(cacheDb);
            if (fallback != null) {
              await downloadedRepo.loadCity(
                fallback.countryKey,
                fallback.cityName,
              );
              compositeRepo.configureDatabaseMode();
            }
            // No fallback → composite stays in uninitialized calculated mode
            // (first-ever launch with no internet — unavoidable).
          },
          (_) async {
            await downloadedRepo.loadCity(countryKey, settings.selectedCity);
            compositeRepo.configureDatabaseMode();
          },
        );
      }
    }
  }

  // ── Audio services ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<INotificationSoundPublisher>(
    () => AndroidMediaStorePublisher(),
  );
  getIt.registerLazySingleton<ICustomAdhanRepository>(
    () => CustomAdhanRepository(
      CustomAdhanFileDataSource(),
      getIt<INotificationSoundPublisher>(),
    ),
  );

  final audioService = AudioService(
    customAdhans: getIt<ICustomAdhanRepository>(),
  );
  getIt.registerSingleton<IAudioRepository>(audioService);
  getIt.registerSingleton<IPrayerAudioPort>(
    platformConfig.isTV ? audioService : NoOpPrayerAudioPort(),
  );

  // Eid Takbeerat — standalone player on TV, silent shim on mobile.
  // Owns its own AudioPlayer so it never collides with the adhan pipeline
  // or the Quran stream.
  getIt.registerSingleton<ITakbeeratAudioPort>(
    platformConfig.isTV ? TakbeeratAudioService() : NoOpTakbeeratAudioPort(),
  );
}

bool _isCalculated(AppSettings settings) {
  return settings.isCalculatedLocation &&
      settings.selectedLatitude != null &&
      settings.selectedLongitude != null;
}
