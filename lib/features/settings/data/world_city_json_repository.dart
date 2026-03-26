import 'dart:convert';
import 'package:flutter/services.dart';

import '../domain/entities/world_city.dart';
import '../domain/i_world_city_repository.dart';

/// Loads and searches the bundled `assets/world_cities.json` catalogue.
///
/// Data is loaded lazily on first access and kept in memory.
class WorldCityJsonRepository implements IWorldCityRepository {
  List<WorldCity>? _cities;
  List<WorldCountry>? _countries;

  Future<void> _ensureLoaded() async {
    if (_cities != null) return;
    final raw = await rootBundle.loadString('assets/world_cities.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _cities = list
        .map((e) => WorldCity(
              name: e['n'] as String,
              arabicName: e['a'] as String,
              countryKey: e['c'] as String,
              countryArabic: e['ca'] as String,
              latitude: (e['lat'] as num).toDouble(),
              longitude: (e['lng'] as num).toDouble(),
              calculationMethod: e['m'] as String,
              utcOffset: (e['tz'] as num).toDouble(),
            ))
        .toList();

    final seen = <String>{};
    final countryList = <WorldCountry>[];
    for (final city in _cities!) {
      if (seen.add(city.countryKey)) {
        countryList.add(WorldCountry(
          key: city.countryKey,
          arabicName: city.countryArabic,
        ));
      }
    }
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
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.arabicName.contains(q) ||
            c.countryKey.toLowerCase().contains(q) ||
            c.countryArabic.contains(q))
        .take(50)
        .toList();
  }

  @override
  Future<void> initialize() => _ensureLoaded();
}
