import '../../features/audio/data/audio_service.dart';
import '../../features/audio/data/noop_prayer_audio_port.dart';
import '../../features/audio/domain/i_audio_repository.dart';
import '../../features/prayer/data/adhan_calculation_source.dart';
import '../../features/prayer/data/calculated_prayer_repository.dart';
import '../../features/prayer/data/composite_prayer_repository.dart';
import '../../features/prayer/data/sqlite_prayer_repository.dart';
import '../../features/prayer/domain/i_prayer_audio_port.dart';
import '../../features/prayer/domain/i_prayer_times_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../injection.dart';
import '../platform_config.dart';

Future<void> registerPrayerServices(
  AppSettings settings,
  PlatformConfig platformConfig,
) async {
  final sqliteRepo = SqlitePrayerRepository();
  final calcRepo = CalculatedPrayerRepository(AdhanCalculationSource());
  final compositeRepo = CompositePrayerRepository(sqliteRepo, calcRepo);

  if (_isCalculated(settings)) {
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
  getIt.registerSingleton<IPrayerAudioPort>(
    platformConfig.isTV ? audioService : NoOpPrayerAudioPort(),
  );
}

bool _isCalculated(AppSettings settings) {
  return settings.isCalculatedLocation &&
      settings.selectedLatitude != null &&
      settings.selectedLongitude != null;
}
