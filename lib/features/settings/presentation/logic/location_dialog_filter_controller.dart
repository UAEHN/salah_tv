import '../../../../core/city_translations.dart';
import '../../domain/entities/world_city.dart';
import '../../domain/i_world_city_repository.dart';
import '../widgets/mobile/mobile_location_search_utils.dart';

/// Owns the mutable filter state for [MobileLocationDialog].
///
/// Pulled out of the dialog State so the StatefulWidget keeps a single
/// responsibility (UI wiring) and stays under the 150-line cap.
class LocationDialogFilterController {
  IWorldCityRepository? worldRepo;
  String? selectedCountryKey;
  bool isSelectedCountryDb = true;
  List<UnifiedCountry> allCountries = [];
  List<UnifiedCountry> filteredCountries = [];
  List<String> filteredDbCities = const [];
  List<WorldCity> filteredWorldCities = const [];
  List<WorldCity> filteredAllWorldCities = const [];

  void Function()? onChanged;

  void initWithDbOnly() {
    allCountries = buildUnifiedCountries(null);
    filteredCountries = allCountries;
  }

  Future<void> loadWorld(
    IWorldCityRepository repo,
    String currentQuery,
  ) async {
    await repo.initialize();
    worldRepo = repo;
    allCountries = buildUnifiedCountries(repo);
    filteredCountries = filterUnifiedCountries(currentQuery, allCountries);
    onChanged?.call();
  }

  void applyQuery(String query) {
    if (selectedCountryKey == null) {
      filteredCountries = filterUnifiedCountries(query, allCountries);
      filteredAllWorldCities = worldRepo == null
          ? const []
          : filterAllWorldCities(query, worldRepo!);
    } else if (isSelectedCountryDb) {
      filteredDbCities = filterDbCities(selectedCountryKey!, query);
    } else if (worldRepo != null) {
      filteredWorldCities = filterWorldCities(
        selectedCountryKey!,
        query,
        worldRepo!,
      );
    }
    onChanged?.call();
  }

  void selectCountry(String key) {
    selectedCountryKey = key;
    isSelectedCountryDb = isDbCountry(key);
    if (isSelectedCountryDb) {
      filteredDbCities = filterDbCities(key, '');
    } else if (worldRepo != null) {
      filteredWorldCities = filterWorldCities(key, '', worldRepo!);
    }
    onChanged?.call();
  }

  void resetToCountries() {
    selectedCountryKey = null;
    filteredDbCities = const [];
    filteredWorldCities = const [];
    filteredAllWorldCities = const [];
    filteredCountries = filterUnifiedCountries('', allCountries);
    onChanged?.call();
  }
}
