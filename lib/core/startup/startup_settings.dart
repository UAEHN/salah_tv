import '../../features/settings/data/online_geocoding_data_source.dart';
import '../../features/settings/data/online_geocoding_repository.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/i_online_geocoding_repository.dart';
import '../../features/settings/domain/i_settings_repository.dart';
import '../../features/settings/domain/usecases/load_settings_usecase.dart';
import '../../injection.dart';

ISettingsRepository registerSettingsRepository() {
  final repo = SettingsRepository();
  getIt.registerSingleton<ISettingsRepository>(repo);
  // Online geocoding (Nominatim) — global city search for users whose city
  // isn't in the bundled `world_cities.json` catalog. Single shared instance.
  getIt.registerLazySingleton<IOnlineGeocodingRepository>(
    () => OnlineGeocodingRepository(OnlineGeocodingDataSource()),
  );
  return repo;
}

Future<AppSettings> loadInitialSettings(ISettingsRepository repo) async {
  return (await LoadSettingsUseCase(
    repo,
  ).call()).fold((_) => const AppSettings(), (settings) => settings);
}
