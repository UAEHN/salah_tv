import 'package:geocoding/geocoding.dart';

import '../../../core/city_translations.dart';
import 'location_text_normalizer.dart';

/// Per-DB-country city aliases used by [LocationCityMatcher]. Keys are
/// normalized via [normalizeLocationText]; values must be exactly one of
/// the country's bundled DB city names. Shared by GPS auto-detect and
/// Nominatim search picks — both route through LocationCityMatcher.
const Map<String, Map<String, String>> kDbCityAliases = {
  'uae': {
    'abu zaby': 'Abu Dhabi',
    'abu dhabi emirate': 'Abu Dhabi',
    'ash shariqah': 'Sharjah',
    'sharjah emirate': 'Sharjah',
    'dubayy': 'Dubai',
    'dubai emirate': 'Dubai',
    'ras al khaimah emirate': 'Ras Al Khaimah',
    // Khor Fakkan & Kalba are enclaves of Sharjah on the eastern coast.
    // Geocoding returns various transliterations — map them all.
    'khorfakkan': 'Khor Fakkan',
    'khor fakkan': 'Khor Fakkan',
    'khawr fakkan': 'Khor Fakkan',
    'khawr fakkan ash shariqah': 'Khor Fakkan',
    'sharjah eastern coast': 'Khor Fakkan',
    'kalba': 'Kalba',
    'kalba ash shariqah': 'Kalba',
    'fujairah emirate': 'Fujairah',
    'al fujayrah': 'Fujairah',
    'umm al quwain emirate': 'Umm Al Quwain',
    'umm al qaywayn': 'Umm Al Quwain',
  },
  'saudi': {
    'ar riyad': 'Riyadh',
    'makkah': 'Mecca',
    'makkah al mukarramah': 'Mecca',
    'al madinah al munawwarah': 'Medina',
  },
  'egypt': {
    'al qahirah': 'Cairo',
    'cairo governorate': 'Cairo',
    'al iskandariyah': 'Alexandria',
  },
  'morocco': {
    'dar el beida': 'Casablanca',
    'casablanca settat': 'Casablanca',
    'tanger assilah': 'Tangier',
  },
};

class LocationCityMatcher {
  String? match(String countryKey, List<Placemark> placemarks) {
    final supportedCities = _supportedCitiesForCountry(countryKey);
    if (supportedCities.isEmpty) return null;

    final normalizedCityMap = {
      for (final city in supportedCities) normalizeLocationText(city): city,
    };
    final countryAliases = kDbCityAliases[countryKey] ?? const {};

    // More-specific candidates (locality, subLocality, name) first,
    // then broader ones (subAdministrativeArea, administrativeArea).
    // This prevents "Ash Shariqah" (emirate) from shadowing "Khor Fakkan" (city).
    final specificCandidates = _specificCandidateNames(placemarks).toList();
    final broadCandidates = _broadCandidateNames(placemarks).toList();
    final allCandidates = [...specificCandidates, ...broadCandidates];

    for (final candidate in allCandidates) {
      final exactMatch = normalizedCityMap[candidate];
      if (exactMatch != null) return exactMatch;

      final aliasMatch = countryAliases[candidate];
      if (aliasMatch != null) return aliasMatch;
    }

    // Strict-normalized pass — handles Arabic city names (locale-localized
    // placemarks on Arabic devices, or Nominatim results in Arabic) where
    // diacritics/spacing differ from the bundled spelling (e.g. Nominatim
    // returns "خور فكان" with a space, db_countries.json has "خورفكان").
    final strictIndex = _buildStrictIndex(supportedCities, countryAliases);
    final strictCandidates = _strictCandidateNames(placemarks).toList();
    for (final candidate in strictCandidates) {
      final hit = strictIndex[candidate];
      if (hit != null) return hit;
    }

    for (final candidate in allCandidates) {
      for (final city in supportedCities) {
        final normalizedCity = normalizeLocationText(city);
        if (_isLooseMatch(candidate, normalizedCity)) {
          return city;
        }
      }
    }

    return null;
  }

  /// Strict-normalized index: every key (English name, Arabic translation
  /// from city_translations, alias) maps to a city in `supportedCities`.
  /// Whitespace is stripped so word-boundary differences (e.g. "خور فكان"
  /// vs "خورفكان") collapse to the same lookup key.
  Map<String, String> _buildStrictIndex(
    List<String> supportedCities,
    Map<String, String> countryAliases,
  ) {
    final index = <String, String>{};
    for (final city in supportedCities) {
      index[normalizeLocationTextStrict(city)] = city;
      final arabic = cityLabel(city, locale: 'ar');
      if (arabic.isNotEmpty && arabic != city) {
        index[normalizeLocationTextStrict(arabic)] = city;
      }
    }
    for (final entry in countryAliases.entries) {
      if (!supportedCities.contains(entry.value)) continue;
      index[normalizeLocationTextStrict(entry.key)] = entry.value;
    }
    return index;
  }

  /// Strict-normalized candidate names — both specific (locality, etc.) and
  /// broad (admin area). Same order as the lax pass so city-level fields
  /// beat region-level fields when both could match.
  Iterable<String> _strictCandidateNames(List<Placemark> placemarks) sync* {
    final seen = <String>{};
    for (final placemark in placemarks.take(3)) {
      for (final value in [
        placemark.locality,
        placemark.subLocality,
        placemark.name,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ]) {
        if (value == null || value.trim().isEmpty) continue;
        final n = normalizeLocationTextStrict(value);
        if (n.isEmpty || !seen.add(n)) continue;
        yield n;
      }
    }
  }

  /// Yields the most-specific fields first (city-level).
  Iterable<String> _specificCandidateNames(List<Placemark> placemarks) sync* {
    for (final placemark in placemarks.take(3)) {
      for (final value in [
        placemark.locality,
        placemark.subLocality,
        placemark.name,
      ]) {
        if (value == null || value.trim().isEmpty) continue;
        final n = normalizeLocationText(value);
        if (n.isNotEmpty) yield n;
      }
    }
  }

  /// Yields broader administrative fields (emirate/region-level).
  Iterable<String> _broadCandidateNames(List<Placemark> placemarks) sync* {
    for (final placemark in placemarks.take(3)) {
      for (final value in [
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ]) {
        if (value == null || value.trim().isEmpty) continue;
        final n = normalizeLocationText(value);
        if (n.isNotEmpty) yield n;
      }
    }
  }

  bool _isLooseMatch(String candidate, String normalizedCity) {
    if (candidate.length < 4 || normalizedCity.length < 4) return false;
    return candidate.contains(normalizedCity) ||
        normalizedCity.contains(candidate);
  }

  List<String> _supportedCitiesForCountry(String countryKey) {
    for (final country in kCountries) {
      if (country.key == countryKey) return country.cities;
    }
    return const [];
  }
}
