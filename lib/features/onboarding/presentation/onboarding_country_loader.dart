import '../../settings/domain/i_world_city_repository.dart';
import '../../settings/presentation/widgets/mobile/mobile_location_search_utils.dart';

class OnboardingCountryLoadResult {
  final IWorldCityRepository worldRepo;
  final List<UnifiedCountry> countries;

  const OnboardingCountryLoadResult({
    required this.worldRepo,
    required this.countries,
  });
}

class OnboardingCountryLoader {
  final IWorldCityRepository _worldRepo;

  const OnboardingCountryLoader(this._worldRepo);

  Future<OnboardingCountryLoadResult> load() async {
    await _worldRepo.initialize();
    final countries = buildUnifiedCountries(_worldRepo);
    return OnboardingCountryLoadResult(
      worldRepo: _worldRepo,
      countries: countries,
    );
  }
}
