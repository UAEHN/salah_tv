import '../../settings/domain/i_settings_repository.dart';
import '../../settings/presentation/settings_provider.dart';
import 'onboarding_state.dart';

class OnboardingCompletionService {
  final SettingsProvider _settings;
  final ISettingsRepository _settingsRepository;

  const OnboardingCompletionService(this._settings, this._settingsRepository);

  Future<void> persistSelection(OnboardingState state) async {
    if (state.isSelectedCountryDb) {
      await _settings.updateLocation(
        state.selectedCountryKey!,
        state.selectedCityKey!,
      );
    } else {
      final worldCity = state.selectedWorldCity!;
      await _settings.updateWorldLocation(
        worldCity.countryArabic,
        worldCity.arabicName,
        worldCity.latitude,
        worldCity.longitude,
        worldCity.calculationMethod,
        utcOffsetHours: worldCity.utcOffset,
      );
    }
    await _settingsRepository.markLaunched();
  }
}
