import 'package:geocoding/geocoding.dart';

import '../../../core/city_translations.dart';
import 'location_text_normalizer.dart';

class LocationCityMatcher {
  static const _aliasesByCountry = <String, Map<String, String>>{
    'UAE': {
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
    'Saudi': {
      'ar riyad': 'Riyadh',
      'makkah': 'Mecca',
      'makkah al mukarramah': 'Mecca',
      'al madinah al munawwarah': 'Medina',
    },
    'Egypt': {
      'al qahirah': 'Cairo',
      'cairo governorate': 'Cairo',
      'al iskandariyah': 'Alexandria',
    },
    'Morocco': {
      'dar el beida': 'Casablanca',
      'casablanca settat': 'Casablanca',
      'tanger assilah': 'Tangier',
    },
  };

  String? match(String countryKey, List<Placemark> placemarks) {
    final supportedCities = _supportedCitiesForCountry(countryKey);
    if (supportedCities.isEmpty) return null;

    final normalizedCityMap = {
      for (final city in supportedCities) normalizeLocationText(city): city,
    };
    final countryAliases = _aliasesByCountry[countryKey] ?? const {};

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
