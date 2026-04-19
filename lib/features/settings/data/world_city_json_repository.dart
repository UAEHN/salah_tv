import 'dart:convert';
import 'package:flutter/services.dart';

import '../domain/entities/world_city.dart';
import '../domain/i_world_city_repository.dart';

/// Loads and searches the bundled `assets/world_cities.json` catalogue for
/// mobile and TV manual location selection.
class WorldCityJsonRepository implements IWorldCityRepository {
  List<WorldCity>? _cities;
  List<WorldCountry>? _countries;

  Future<void> _ensureLoaded() async {
    if (_cities != null) return;
    final raw = await rootBundle.loadString('assets/world_cities.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    // Schema: { "countries": { "<key>": "<arabicName>" },
    //           "cities":    [ { n, a, c, lat, lng, m, tz, alt? }, ... ] }
    // Country Arabic lives on the country map (not per-city) to avoid
    // duplicating the same country name across every city.
    final countryArabic = (data['countries'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, v as String),
    );
    final list = (data['cities'] as List).cast<Map<String, dynamic>>();

    _cities = list
        .map(
          (e) => WorldCity(
            name: e['n'] as String,
            arabicName: e['a'] as String,
            countryKey: e['c'] as String,
            countryArabic: countryArabic[e['c']] ?? e['c'] as String,
            latitude: (e['lat'] as num).toDouble(),
            longitude: (e['lng'] as num).toDouble(),
            calculationMethod: e['m'] as String,
            timeZoneId: e['tzn'] as String?,
            utcOffset: (e['tz'] as num).toDouble(),
          ),
        )
        .toList();

    final countryList = countryArabic.entries
        .map((e) => WorldCountry(key: e.key, arabicName: e.value))
        .toList();
    countryList.sort((a, b) => a.arabicName.compareTo(b.arabicName));
    _countries = countryList;
  }

  @override
  List<WorldCountry> get countries => _countries ?? const [];

  @override
  List<WorldCity> citiesForCountry(String countryKey) {
    return (_cities ?? const [])
        .where((c) => c.countryKey == countryKey)
        .toList();
  }

  @override
  List<WorldCity> searchCities(String query) {
    if (_cities == null || query.trim().isEmpty) return const [];
    final q = query.trim().toLowerCase();
    return _cities!
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.arabicName.contains(q) ||
              c.countryKey.toLowerCase().contains(q) ||
              c.countryArabic.contains(q),
        )
        .take(50)
        .toList();
  }

  @override
  WorldCity? resolveDetectedCity({
    required String countryKey,
    required String cityName,
    required double latitude,
    required double longitude,
  }) {
    final cities = citiesForCountry(countryKey.toUpperCase());
    if (cities.isEmpty) return null;

    final normalizedName = cityName.trim().toLowerCase();
    if (normalizedName.isNotEmpty) {
      for (final city in cities) {
        if (city.name.toLowerCase() == normalizedName ||
            city.arabicName == cityName.trim()) {
          return city;
        }
      }
    }

    WorldCity? nearest;
    double? nearestDistance;
    for (final city in cities) {
      final distance = _distanceSquared(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (nearestDistance == null || distance < nearestDistance) {
        nearestDistance = distance;
        nearest = city;
      }
    }
    return nearest;
  }

  double _distanceSquared(double lat1, double lng1, double lat2, double lng2) {
    final dLat = lat1 - lat2;
    final dLng = lng1 - lng2;
    return (dLat * dLat) + (dLng * dLng);
  }

  @override
  Future<void> initialize() => _ensureLoaded();
}
