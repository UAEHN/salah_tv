import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/i_settings_repository.dart';
import '../../features/settings/domain/usecases/load_settings_usecase.dart';
import '../../injection.dart';

ISettingsRepository registerSettingsRepository() {
  final repo = SettingsRepository();
  getIt.registerSingleton<ISettingsRepository>(repo);
  return repo;
}

Future<AppSettings> loadInitialSettings(ISettingsRepository repo) async {
  return (await LoadSettingsUseCase(
    repo,
  ).call()).fold((_) => const AppSettings(), (settings) => settings);
}
