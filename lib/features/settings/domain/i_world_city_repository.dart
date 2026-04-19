import 'entities/world_city.dart';

/// Provides access to the bundled worldwide city catalogue (JSON asset).
///
/// Used for manual location selection on mobile and TV when the user's city
/// is not in the pre-computed SQLite prayer-time database.
abstract class IWorldCityRepository {
  /// Loads data from the asset. Must be called before synchronous access.
  Future<void> initialize();

  /// All available countries sorted alphabetically by Arabic name.
  List<WorldCountry> get countries;

  /// Cities belonging to [countryKey].
  List<WorldCity> citiesForCountry(String countryKey);

  /// Free-text search across city and country names (Arabic + English).
  List<WorldCity> searchCities(String query);

  /// Returns the best matching city for a detected location.
  ///
  /// Tries an exact city-name match inside [countryKey] first, then falls back
  /// to the nearest bundled city by coordinates. Returns null when the country
  /// has no bundled world-city entries.
  WorldCity? resolveDetectedCity({
    required String countryKey,
    required String cityName,
    required double latitude,
    required double longitude,
  });
}
