import '../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../features/prayer/domain/cancellation_token.dart';
import '../../../features/prayer/domain/usecases/i_download_city_use_case.dart';
import '../../settings/domain/i_settings_repository.dart';
import '../../settings/presentation/settings_provider.dart';
import 'onboarding_state.dart';

class OnboardingCompletionService {
  final SettingsProvider _settings;
  final ISettingsRepository _settingsRepository;
  final IDownloadCityUseCase _downloadCityUseCase;
  final CompositePrayerRepository _compositeRepo;

  const OnboardingCompletionService(
    this._settings,
    this._settingsRepository,
    this._downloadCityUseCase,
    this._compositeRepo,
  );

  Future<void> persistSelection(OnboardingState state) async {
    if (state.isSelectedCountryDb) {
      final countryKey = state.selectedCountryKey!;
      final cityName = state.selectedCityKey!;
      await _settings.updateLocation(countryKey, cityName);
      final result = await _downloadCityUseCase(
        countryKey: countryKey,
        cityName: cityName,
        cancelToken: CancellationToken(),
      );
      await result.fold(
        (_) async {},
        (_) async {
          await _compositeRepo.downloadedRepo.loadCity(countryKey, cityName);
          _compositeRepo.configureDatabaseMode();
        },
      );
    } else {
      final worldCity = state.selectedWorldCity!;
      await _settings.updateWorldLocation(
        worldCity.countryKey,
        worldCity.name,
        worldCity.latitude,
        worldCity.longitude,
        worldCity.calculationMethod,
        timeZoneId: worldCity.timeZoneId,
        utcOffsetHours: worldCity.utcOffset,
      );
    }
    await _settingsRepository.markLaunched();
  }
}
