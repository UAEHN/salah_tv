import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../features/adhkar/data/adhkar_audio_service.dart';
import '../features/adhkar/data/adhkar_json_repository.dart';
import '../features/adhkar/domain/i_adhkar_audio_port.dart';
import '../features/adhkar/domain/i_adhkar_state_repository.dart';
import '../features/audio/data/audio_service.dart';
import '../features/audio/domain/i_audio_repository.dart';
import '../features/prayer/data/sqlite_prayer_repository.dart';
import '../features/prayer/domain/i_prayer_audio_port.dart';
import '../features/prayer/domain/i_prayer_times_repository.dart';
import '../features/quran/data/quran_api_service.dart';
import '../features/quran/domain/i_quran_api_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/i_settings_repository.dart';
import '../features/settings/domain/usecases/load_settings_usecase.dart';
import '../injection.dart';
import 'platform_config.dart';

/// Composition root: initialises all services and registers them in get_it.
/// Returns the loaded [AppSettings] so [main] can pass it to the widget tree.
Future<AppSettings> initDependencies() async {
  // Register app_update services (Dio, UpdateBloc, etc.) via injectable
  configureDependencies();

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

  // SqlitePrayerRepository requires async init before it can be registered.
  final prayerRepo = SqlitePrayerRepository();
  await prayerRepo.initialize(settings.selectedCountry);
  getIt.registerSingleton<IPrayerTimesRepository>(prayerRepo);

  final audioService = AudioService();
  getIt.registerSingleton<IAudioRepository>(audioService);
  getIt.registerSingleton<IPrayerAudioPort>(audioService);

  final adhkarRepo = AdhkarJsonRepository();
  await adhkarRepo.initialize();
  getIt.registerSingleton<AdhkarJsonRepository>(adhkarRepo);
  getIt.registerSingleton<IAdhkarStateRepository>(adhkarRepo);
  getIt.registerSingleton<IAdhkarAudioPort>(AdhkarAudioService());

  getIt.registerLazySingleton<IQuranApiRepository>(
    () => QuranApiService(getIt<Dio>()),
  );

  return settings;
}
