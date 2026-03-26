import 'entities/world_city.dart';

/// Provides access to the bundled worldwide city catalogue (JSON asset).
///
/// Used for manual location selection on mobile when the user's city
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
}
