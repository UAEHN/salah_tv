import '../../../../../core/city_translations.dart';
import '../../../domain/entities/world_city.dart';
import '../../../domain/i_world_city_repository.dart';

/// Unified country entry for the merged location picker.
/// Represents both DB-backed countries and world-only countries.
class UnifiedCountry {
  final String key;
  final String arabicName;
  final bool isInDb;

  const UnifiedCountry({
    required this.key,
    required this.arabicName,
    required this.isInDb,
  });
}

// O(1) country lookup — built once at library-load time
final _kCountryIndex = Map<String, CountryInfo>.fromEntries(
  kCountries.map((c) => MapEntry(c.key, c)),
);

/// Builds a merged list of DB + world countries (DB countries first).
/// World countries that already exist in the DB are excluded.
List<UnifiedCountry> buildUnifiedCountries(IWorldCityRepository? worldRepo) {
  final dbEntries = kCountries.map(
    (c) => UnifiedCountry(key: c.key, arabicName: c.arabicName, isInDb: true),
  );
  if (worldRepo == null) return dbEntries.toList();

  final dbKeys = kDbCountryKeys;
  final worldEntries = worldRepo.countries
      .where((w) => !dbKeys.contains(w.key))
      .map((w) => UnifiedCountry(
            key: w.key,
            arabicName: w.arabicName,
            isInDb: false,
          ));
  return [...dbEntries, ...worldEntries];
}

List<UnifiedCountry> filterUnifiedCountries(
  String query,
  List<UnifiedCountry> allCountries,
) {
  return allCountries.where((country) {
    return _matchesQuery(query, [country.key, country.arabicName]);
  }).toList();
}

/// DB city keys for a DB country.
List<String> filterDbCities(String countryKey, String query) {
  final country = _kCountryIndex[countryKey];
  if (country == null) return [];
  return country.cities.where((city) {
    return _matchesQuery(query, [city, cityLabel(city)]);
  }).toList();
}

/// World cities for a non-DB country.
List<WorldCity> filterWorldCities(
  String countryKey,
  String query,
  IWorldCityRepository worldRepo,
) {
  final cities = worldRepo.citiesForCountry(countryKey);
  if (query.trim().isEmpty) return cities;
  return cities.where((c) {
    return _matchesQuery(query, [c.name, c.arabicName]);
  }).toList();
}

String locationSearchHint(bool showCities) {
  return showCities ? 'ابحث عن مدينة' : 'ابحث عن دولة';
}

bool _matchesQuery(String query, List<String> values) {
  final normalizedQuery = _normalizeQuery(query);
  if (normalizedQuery.isEmpty) return true;
  return values.any(
    (value) => _normalizeQuery(value).contains(normalizedQuery),
  );
}

/// Strips Arabic diacritics (tashkeel) and normalizes alef variants
/// for loose matching. Range u064B-u065F covers only harakat, not letters.
String _normalizeQuery(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[\u064B-\u065F]'), '') // tashkeel only
      .replaceAll(RegExp('[إأآ]'), 'ا') // normalize alef variants
      .replaceAll('ة', 'ه'); // normalize teh marbuta
}
