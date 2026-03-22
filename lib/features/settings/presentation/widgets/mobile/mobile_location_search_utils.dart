import '../../../../../core/city_translations.dart';

// O(1) country lookup — built once at library-load time
final _kCountryIndex = Map<String, CountryInfo>.fromEntries(
  kCountries.map((c) => MapEntry(c.key, c)),
);

List<CountryInfo> filterCountries(String query) {
  return kCountries.where((country) {
    return _matchesQuery(query, [country.key, country.arabicName]);
  }).toList();
}

List<String> filterCities(String countryKey, String query) {
  final country = _kCountryIndex[countryKey];
  if (country == null) return [];
  return country.cities.where((city) {
    return _matchesQuery(query, [city, cityLabel(city)]);
  }).toList();
}

String locationSearchHint(bool showCities) {
  return showCities ? 'ابحث عن مدينة' : 'ابحث عن دولة';
}

bool _matchesQuery(String query, List<String> values) {
  final normalizedQuery = _normalizeQuery(query);
  if (normalizedQuery.isEmpty) {
    return true;
  }
  return values.any(
    (value) => _normalizeQuery(value).contains(normalizedQuery),
  );
}

String _normalizeQuery(String value) {
  return value.trim().toLowerCase();
}
