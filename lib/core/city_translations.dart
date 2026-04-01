import 'dart:convert';
import 'package:flutter/services.dart';

// ── Country definitions ──────────────────────────────────────────────────────

class CountryInfo {
  final String key;
  final String arabicName;
  final String englishName;
  final List<String> cities;

  const CountryInfo({
    required this.key,
    required this.arabicName,
    required this.englishName,
    required this.cities,
  });
}

// ── Lazily loaded data from assets/db_countries.json ─────────────────────────

List<CountryInfo> _countries = const [];
Map<String, String> _cityArabic = const {};
Set<String> _dbCountryKeys = const {};
bool _loaded = false;

/// Must be called once during startup (from [initDependencies]).
Future<void> loadCityTranslations() async {
  if (_loaded) return;
  final raw = await rootBundle.loadString('assets/db_countries.json');
  final data = jsonDecode(raw) as Map<String, dynamic>;

  final countriesList = (data['countries'] as List).cast<Map<String, dynamic>>();
  _countries = countriesList
      .map((c) => CountryInfo(
            key: c['key'] as String,
            arabicName: c['arabicName'] as String,
            englishName: (c['englishName'] as String?) ?? c['key'] as String,
            cities: (c['cities'] as List).cast<String>(),
          ))
      .toList();

  _cityArabic = (data['cityArabic'] as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, v as String));

  _dbCountryKeys = _countries.map((c) => c.key).toSet();
  _loaded = true;
}

// ── Public API (same signatures as before) ───────────────────────────────────

List<CountryInfo> get kCountries => _countries;

Set<String> get kDbCountryKeys => _dbCountryKeys;

bool isDbCountry(String countryKey) => _dbCountryKeys.contains(countryKey);

String countryLabel(String key, {String locale = 'ar'}) {
  for (final c in _countries) {
    if (c.key == key) return locale == 'en' ? c.englishName : c.arabicName;
  }
  return key;
}

String countryForCity(String cityKey) {
  for (final c in _countries) {
    if (c.cities.contains(cityKey)) return c.key;
  }
  return '';
}

List<String> citiesForCountry(
  String countryKey,
  List<String> availableCities,
) {
  for (final c in _countries) {
    if (c.key == countryKey) {
      return availableCities.where((city) => c.cities.contains(city)).toList();
    }
  }
  return availableCities;
}

String cityLabel(String englishKey, {String locale = 'ar'}) =>
    locale == 'en' ? englishKey : (_cityArabic[englishKey] ?? englishKey);
