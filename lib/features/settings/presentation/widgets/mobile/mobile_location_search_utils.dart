import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../domain/entities/world_city.dart';
import '../../../domain/i_world_city_repository.dart';

/// Unified country entry for the merged location picker.
/// Represents both DB-backed countries and world-only countries.
class UnifiedCountry {
  final String key;
  final String arabicName;
  final String englishName;
  final bool isInDb;

  const UnifiedCountry({
    required this.key,
    required this.arabicName,
    required this.englishName,
    required this.isInDb,
  });
}

final _kCountryIndex = Map<String, CountryInfo>.fromEntries(
  kCountries.map((c) => MapEntry(c.key, c)),
);

List<UnifiedCountry> buildUnifiedCountries(IWorldCityRepository? worldRepo) {
  final dbEntries = kCountries.map(
    (c) => UnifiedCountry(
      key: c.key,
      arabicName: c.arabicName,
      englishName: c.englishName,
      isInDb: true,
    ),
  );
  if (worldRepo == null) return dbEntries.toList();

  final dbKeys = kDbCountryKeys;
  final worldEntries = worldRepo.countries
      .where((w) => !dbKeys.contains(w.key))
      .map((w) => UnifiedCountry(
            key: w.key,
            arabicName: w.arabicName,
            englishName: w.key,
            isInDb: false,
          ));
  return [...dbEntries, ...worldEntries];
}

List<UnifiedCountry> filterUnifiedCountries(
  String query,
  List<UnifiedCountry> allCountries,
) {
  return allCountries.where((country) {
    return _matchesQuery(
        query, [country.key, country.arabicName, country.englishName]);
  }).toList();
}

List<String> filterDbCities(String countryKey, String query) {
  final country = _kCountryIndex[countryKey];
  if (country == null) return [];
  return country.cities.where((city) {
    return _matchesQuery(query, [city, cityLabel(city)]);
  }).toList();
}

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

String locationSearchHint(BuildContext context, bool showCities) {
  final l = AppLocalizations.of(context);
  return showCities ? l.settingsSearchCity : l.settingsSearchCountry;
}

bool _matchesQuery(String query, List<String> values) {
  final normalizedQuery = _normalizeQuery(query);
  if (normalizedQuery.isEmpty) return true;
  return values.any(
    (value) => _normalizeQuery(value).contains(normalizedQuery),
  );
}

/// Strips Arabic diacritics and normalizes common Arabic variants.
String _normalizeQuery(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[\u064B-\u065F]'), '')
      .replaceAll(RegExp('[\u0625\u0623\u0622]'), '\u0627')
      .replaceAll('\u0629', '\u0647');
}
