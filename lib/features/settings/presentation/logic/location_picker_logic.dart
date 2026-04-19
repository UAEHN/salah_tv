import '../../../../core/city_translations.dart';
import '../../../../core/country_name_resolver.dart';
import '../../domain/i_world_city_repository.dart';
import '../bloc/location_choice.dart';
import '../bloc/location_picker_source.dart';

class UnifiedCountry {
  final String key;
  final String arabicName;
  final String englishName;
  final LocationPickerSource source;

  const UnifiedCountry({
    required this.key,
    required this.arabicName,
    required this.englishName,
    required this.source,
  });

  bool get isInDb => source == LocationPickerSource.db;
}

// Computed per call so the index reflects the current DB-discovered countries.
// Cheap: ~15 entries. Don't cache — registerDbCountries may rebuild the list.
Map<String, CountryInfo> _countryIndex() => {
  for (final c in kCountries) c.key: c,
};

List<UnifiedCountry> buildUnifiedCountries(IWorldCityRepository? worldRepo) {
  final dbEntries = kCountries.map(
    (c) => UnifiedCountry(
      key: c.key,
      arabicName: c.arabicName,
      englishName: c.englishName,
      source: LocationPickerSource.db,
    ),
  );
  if (worldRepo == null) return dbEntries.toList();

  // DB-backed countries always win: if a world entry's ISO code maps to a
  // country that's currently in the DB, hide the world entry so the user
  // can't accidentally pick the calculated-mode duplicate. DB times are
  // pre-computed by the local authority; calculated lat/lng is a fallback.
  final dbKeys = kDbCountryKeys;
  final worldEntries = worldRepo.countries
      .where((w) {
        final mappedDbKey = dbCountryKeyForIso(w.key);
        if (mappedDbKey != null && dbKeys.contains(mappedDbKey)) return false;
        return !dbKeys.contains(w.key);
      })
      .map(
        (w) => UnifiedCountry(
          key: w.key,
          arabicName: w.arabicName,
          englishName: resolveEnglishCountryName(w.key),
          source: LocationPickerSource.world,
        ),
      );
  return [...dbEntries, ...worldEntries];
}

List<UnifiedCountry> filterUnifiedCountries(
  String query,
  List<UnifiedCountry> allCountries,
) {
  return allCountries.where((country) {
    return matchesLocationQuery(query, [
      country.key,
      country.arabicName,
      country.englishName,
    ]);
  }).toList();
}

List<LocationChoice> buildCountryChoices(
  UnifiedCountry country,
  IWorldCityRepository? worldRepo,
) {
  if (country.isInDb) {
    final dbCountry = _countryIndex()[country.key];
    if (dbCountry == null) return const [];
    return dbCountry.cities
        .map(
          (city) =>
              LocationChoice.database(countryKey: country.key, cityName: city),
        )
        .toList();
  }
  if (worldRepo == null) return const [];
  return worldRepo
      .citiesForCountry(country.key)
      .map(LocationChoice.world)
      .toList();
}

List<LocationChoice> filterLocationChoices(
  String query,
  List<LocationChoice> choices,
) {
  return choices.where((choice) {
    return matchesLocationQuery(query, [
      choice.cityName,
      cityLabel(choice.cityName, countryKey: choice.countryKey),
      choice.countryKey,
      countryLabel(choice.countryKey),
      countryLabel(choice.countryKey, locale: 'en'),
    ]);
  }).toList();
}

bool matchesLocationQuery(String query, List<String> values) {
  final normalizedQuery = normalizeLocationSearchQuery(query);
  if (normalizedQuery.isEmpty) return true;
  return values.any(
    (value) => normalizeLocationSearchQuery(value).contains(normalizedQuery),
  );
}

String normalizeLocationSearchQuery(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[\u064B-\u065F]'), '')
      .replaceAll(RegExp('[\u0625\u0623\u0622]'), '\u0627')
      .replaceAll('\u0629', '\u0647');
}
