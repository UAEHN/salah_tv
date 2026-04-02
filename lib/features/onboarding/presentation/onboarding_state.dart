import '../../settings/domain/entities/world_city.dart';
import '../../settings/domain/i_world_city_repository.dart';
import '../../settings/presentation/widgets/mobile/mobile_location_search_utils.dart';

class OnboardingState {
  final int step;
  final String locale;
  final String? selectedCountryKey;
  final bool isSelectedCountryDb;
  final String? selectedCityKey;
  final WorldCity? selectedWorldCity;
  final bool isLoading;
  final bool isComplete;
  final List<UnifiedCountry> allCountries;
  final List<UnifiedCountry> filteredCountries;
  final List<String> filteredDbCities;
  final List<WorldCity> filteredWorldCities;
  final IWorldCityRepository? worldRepo;

  const OnboardingState({
    this.step = 0,
    this.locale = 'ar',
    this.selectedCountryKey,
    this.isSelectedCountryDb = true,
    this.selectedCityKey,
    this.selectedWorldCity,
    this.isLoading = false,
    this.isComplete = false,
    this.allCountries = const [],
    this.filteredCountries = const [],
    this.filteredDbCities = const [],
    this.filteredWorldCities = const [],
    this.worldRepo,
  });

  OnboardingState copyWith({
    int? step,
    String? locale,
    String? selectedCountryKey,
    bool? isSelectedCountryDb,
    String? selectedCityKey,
    WorldCity? selectedWorldCity,
    bool clearCity = false,
    bool? isLoading,
    bool? isComplete,
    List<UnifiedCountry>? allCountries,
    List<UnifiedCountry>? filteredCountries,
    List<String>? filteredDbCities,
    List<WorldCity>? filteredWorldCities,
    IWorldCityRepository? worldRepo,
  }) => OnboardingState(
    step: step ?? this.step,
    locale: locale ?? this.locale,
    selectedCountryKey: selectedCountryKey ?? this.selectedCountryKey,
    isSelectedCountryDb: isSelectedCountryDb ?? this.isSelectedCountryDb,
    selectedCityKey: clearCity
        ? null
        : (selectedCityKey ?? this.selectedCityKey),
    selectedWorldCity: clearCity
        ? null
        : (selectedWorldCity ?? this.selectedWorldCity),
    isLoading: isLoading ?? this.isLoading,
    isComplete: isComplete ?? this.isComplete,
    allCountries: allCountries ?? this.allCountries,
    filteredCountries: filteredCountries ?? this.filteredCountries,
    filteredDbCities: filteredDbCities ?? this.filteredDbCities,
    filteredWorldCities: filteredWorldCities ?? this.filteredWorldCities,
    worldRepo: worldRepo ?? this.worldRepo,
  );
}
