import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../features/prayer/domain/cancellation_token.dart';
import '../../../features/prayer/domain/usecases/i_download_city_use_case.dart';
import '../../settings/domain/i_settings_repository.dart';
import '../../settings/presentation/settings_provider.dart';
import 'onboarding_state.dart';

/// Persists the onboarding location choice atomically.
///
/// For DB countries: download → prime cache → write settings → mark launched.
/// If the download fails, settings remain untouched and the failure surfaces
/// to the cubit so the UI can stay on the onboarding step with an error.
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

  Future<Either<Failure, Success>> persistSelection(
    OnboardingState state,
  ) async {
    if (state.isSelectedCountryDb) {
      final countryKey = state.selectedCountryKey!;
      final cityName = state.selectedCityKey!;
      final result = await _downloadCityUseCase(
        countryKey: countryKey,
        cityName: cityName,
        cancelToken: CancellationToken(),
      );
      return result.fold(
        (failure) async => Left(failure),
        (_) async {
          await _compositeRepo.downloadedRepo.loadCity(countryKey, cityName);
          _compositeRepo.configureDatabaseMode();
          await _settings.updateLocation(countryKey, cityName);
          await _settingsRepository.markLaunched();
          return const Right(Success());
        },
      );
    }

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
    await _settingsRepository.markLaunched();
    return const Right(Success());
  }
}
