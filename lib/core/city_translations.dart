import 'dart:convert';
import 'package:flutter/services.dart';

import 'country_name_resolver.dart';

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

// ── Translations (from assets/db_countries.json — small dictionary only) ─────
// Country + city *lists* come from the SQLite DB; this file maps keys → labels.

class _CountryLabel {
  final String ar;
  final String en;
  const _CountryLabel(this.ar, this.en);
}

Map<String, _CountryLabel> _countryLabels = const {};
Map<String, String> _cityArabic = const {};

// ── DB-country state (populated after SQLite opens) ──────────────────────────

List<CountryInfo> _countries = const [];
Set<String> _dbCountryKeys = const {};

// ── World-city translations (assets/world_cities.json) ───────────────────────

Map<String, String> _worldCountryArabicByKey = const {};
Map<String, String> _worldCountryKeyByArabic = const {};
Map<String, String> _worldCityArabicByKey = const {};
Map<String, String> _worldCityEnglishByArabicKey = const {};

bool _loaded = false;

/// Loads the translation dictionary + world-city data. Call once at startup
/// before opening the SQLite DB. DB-country list is populated separately via
/// [registerDbCountries] once the DB is open.
Future<void> loadCityTranslations() async {
  if (_loaded) return;

  final raw = await rootBundle.loadString('assets/db_countries.json');
  final data = jsonDecode(raw) as Map<String, dynamic>;

  final countryMap = <String, _CountryLabel>{};
  (data['countries'] as Map<String, dynamic>).forEach((k, v) {
    final m = v as Map<String, dynamic>;
    countryMap[k.toLowerCase()] = _CountryLabel(
      m['ar'] as String,
      (m['en'] as String?) ?? k,
    );
  });
  _countryLabels = countryMap;

  _cityArabic = (data['cities'] as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, v as String),
  );

  final worldRaw = await rootBundle.loadString('assets/world_cities.json');
  final worldData = jsonDecode(worldRaw) as Map<String, dynamic>;
  final worldCountryMap = (worldData['countries'] as Map<String, dynamic>)
      .map((k, v) => MapEntry(k.toUpperCase(), v as String));
  final worldList = (worldData['cities'] as List).cast<Map<String, dynamic>>();

  final worldCountryArabicByKey = <String, String>{...worldCountryMap};
  final worldCountryKeyByArabic = <String, String>{
    for (final e in worldCountryMap.entries) e.value: e.key,
  };
  final worldCityArabicByKey = <String, String>{};
  final worldCityEnglishByArabicKey = <String, String>{};
  for (final city in worldList) {
    final countryKey = (city['c'] as String).toUpperCase();
    final englishName = city['n'] as String;
    final arabicName = city['a'] as String;
    worldCityArabicByKey[_worldCityMapKey(countryKey, englishName)] =
        arabicName;
    worldCityEnglishByArabicKey[_worldCityMapKey(countryKey, arabicName)] =
        englishName;
  }
  _worldCountryArabicByKey = worldCountryArabicByKey;
  _worldCountryKeyByArabic = worldCountryKeyByArabic;
  _worldCityArabicByKey = worldCityArabicByKey;
  _worldCityEnglishByArabicKey = worldCityEnglishByArabicKey;

  _loaded = true;
}

/// Registers the DB-backed countries discovered at runtime from prayer_times.db.
/// [countryToCities] keys are DB country keys (lowercase); values are the
/// English city names stored in the `cities` table for that country.
///
/// Arabic/English labels are resolved from [_countryLabels]; if a key has no
/// translation, the key itself is shown (visible fallback, no crash).
void registerDbCountries(Map<String, List<String>> countryToCities) {
  final list = <CountryInfo>[];
  countryToCities.forEach((key, cities) {
    final label = _countryLabels[key];
    list.add(
      CountryInfo(
        key: key,
        arabicName: label?.ar ?? key,
        englishName: label?.en ?? key,
        cities: List.unmodifiable(cities),
      ),
    );
  });
  _countries = List.unmodifiable(list);
  _dbCountryKeys = Set.unmodifiable(_countries.map((c) => c.key).toSet());
}

// ── Public API ───────────────────────────────────────────────────────────────

List<CountryInfo> get kCountries => _countries;

Set<String> get kDbCountryKeys => _dbCountryKeys;

bool isDbCountry(String countryKey) =>
    _dbCountryKeys.contains(countryKey.toLowerCase());

/// Normalizes a country key to its canonical stored form:
/// - Matches DB countries case-insensitively (DB stores lowercase).
/// - Falls back to the uppercase ISO-2 code used by world_cities.json.
/// - Or reverse-resolves an Arabic country name to its world key.
String normalizeCountryKey(String key) {
  final trimmed = key.trim();
  if (trimmed.isEmpty) return trimmed;

  final lower = trimmed.toLowerCase();
  if (_dbCountryKeys.contains(lower)) return lower;

  final upper = trimmed.toUpperCase();
  if (_worldCountryArabicByKey.containsKey(upper)) return upper;

  return _worldCountryKeyByArabic[trimmed] ?? trimmed;
}

String countryLabel(String key, {String locale = 'ar'}) {
  final lower = key.toLowerCase();
  final dbLabel = _countryLabels[lower];
  if (dbLabel != null && _dbCountryKeys.contains(lower)) {
    return locale == 'en' ? dbLabel.en : dbLabel.ar;
  }

  final normalizedKey = normalizeCountryKey(key);
  if (locale == 'en') return resolveEnglishCountryName(normalizedKey);
  return _worldCountryArabicByKey[normalizedKey] ?? key;
}

String countryForCity(String cityKey) {
  for (final c in _countries) {
    if (c.cities.contains(cityKey)) return c.key;
  }
  return '';
}

/// DB is authoritative: [availableCities] already reflects the active country.
/// Kept as a pass-through so callers don't need to change.
List<String> citiesForCountry(String countryKey, List<String> availableCities) {
  return availableCities;
}

String cityLabel(String cityKey, {String locale = 'ar', String? countryKey}) {
  if (locale == 'en') {
    if (countryKey != null) {
      final normalizedCountryKey = normalizeCountryKey(countryKey);
      final worldEnglish =
          _worldCityEnglishByArabicKey[_worldCityMapKey(
            normalizedCountryKey,
            cityKey,
          )];
      if (worldEnglish != null) return worldEnglish;
    }
    return cityKey;
  }

  final dbArabic = _cityArabic[cityKey];
  if (dbArabic != null) return dbArabic;

  if (countryKey != null) {
    final normalizedCountryKey = normalizeCountryKey(countryKey);
    final worldArabic =
        _worldCityArabicByKey[_worldCityMapKey(normalizedCountryKey, cityKey)];
    if (worldArabic != null) return worldArabic;
  }
  return cityKey;
}

String _worldCityMapKey(String countryKey, String cityName) =>
    '${countryKey.toUpperCase()}::$cityName';
