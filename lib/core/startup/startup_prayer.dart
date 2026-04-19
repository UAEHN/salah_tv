import '../../features/audio/data/audio_service.dart';
import '../../features/audio/data/noop_prayer_audio_port.dart';
import '../../features/audio/domain/i_audio_repository.dart';
import '../../features/prayer/data/adhan_calculation_source.dart';
import '../../features/prayer/data/calculated_prayer_repository.dart';
import '../../features/prayer/data/composite_prayer_repository.dart';
import '../../features/prayer/data/sqlite_prayer_repository.dart';
import '../../features/prayer/domain/i_prayer_audio_port.dart';
import '../../features/prayer/domain/i_prayer_times_repository.dart';
import '../../features/settings/data/android_media_store_publisher.dart';
import '../../features/settings/data/custom_adhan_repository.dart';
import '../../features/settings/data/datasources/custom_adhan_file_datasource.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/i_custom_adhan_repository.dart';
import '../../features/settings/domain/i_notification_sound_publisher.dart';
import '../../injection.dart';
import '../city_translations.dart';
import '../platform_config.dart';

Future<void> registerPrayerServices(
  AppSettings settings,
  PlatformConfig platformConfig,
) async {
  final sqliteRepo = SqlitePrayerRepository();
  final calcRepo = CalculatedPrayerRepository(AdhanCalculationSource());
  final compositeRepo = CompositePrayerRepository(sqliteRepo, calcRepo);

  // Open DB first so we can enumerate the countries it actually contains —
  // this is the single source of truth. The UI picks up any new country as
  // soon as the bundled DB ships it; no JSON edit required.
  await sqliteRepo.openOnly();
  final dbCountries = await sqliteRepo.fetchAllCountriesWithCities();
  registerDbCountries(dbCountries);

  if (_isCalculated(settings)) {
    // Bootstrap sqlite repo with any valid country so switches back to DB
    // mode don't race against an unloaded repo.
    final bootstrap = _resolveCountryKey(settings.selectedCountry, dbCountries);
    if (bootstrap != null) await sqliteRepo.loadCountry(bootstrap);
    calcRepo.configureCalculatedMode(
      settings.selectedLatitude!,
      settings.selectedLongitude!,
      settings.calculationMethod,
      madhabKey: settings.madhab,
      cityLabel: settings.selectedCity,
      timeZoneId: settings.selectedTimeZoneId,
      utcOffsetHours: settings.utcOffsetHours,
    );
    compositeRepo.setMode(isCalculated: true);
  } else {
    final resolved = _resolveCountryKey(settings.selectedCountry, dbCountries);
    if (resolved != null) await sqliteRepo.loadCountry(resolved);
    compositeRepo.setMode(isCalculated: false);
  }

  getIt.registerSingleton<IPrayerTimesRepository>(compositeRepo);

  // Custom-adhan repo is registered regardless of platform so [AudioService]
  // can resolve `custom:*` keys uniformly; the picker UI is mobile-only.
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
}

bool _isCalculated(AppSettings settings) {
  return settings.isCalculatedLocation &&
      settings.selectedLatitude != null &&
      settings.selectedLongitude != null;
}

/// Returns [settings.selectedCountry] (lowercased) if it exists in the DB,
/// otherwise the first DB country, or null if the DB is empty. This prevents
/// the app from sitting on a stale country key after a DB rebuild drops it.
String? _resolveCountryKey(
  String saved,
  Map<String, List<String>> dbCountries,
) {
  if (dbCountries.isEmpty) return null;
  final lower = saved.toLowerCase();
  if (dbCountries.containsKey(lower)) return lower;
  return dbCountries.keys.first;
}
