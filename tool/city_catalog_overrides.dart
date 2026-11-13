import 'dart:convert';
import 'dart:io';

/// Applies explicit catalog management without changing any prayer-time rows.
Map<String, dynamic> applyCityCatalogOverrides(
  Map<String, dynamic> generated, {
  String path = 'assets/city_catalog_overrides.json',
}) {
  final file = File(path);
  if (!file.existsSync()) return generated;
  final config = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final overrides = config['countries'] as Map<String, dynamic>? ?? {};
  final result = <String, dynamic>{...generated};
  for (final entry in overrides.entries) {
    if (entry.key != entry.key.toLowerCase() || entry.key.trim().isEmpty) {
      throw FormatException(
        'Catalog country keys must be lowercase: ${entry.key}',
      );
    }
    final patch = entry.value as Map<String, dynamic>;
    final existing = result[entry.key] as Map<String, dynamic>? ?? {};
    final cities = <String, Map<String, dynamic>>{};
    String identity(Map<String, dynamic> city) =>
        (city['id'] ??
                city['slug'] ??
                (city['en'] as String)
                    .toLowerCase()
                    .replaceAll("'", '')
                    .replaceAll(' ', '_'))
            as String;
    for (final city
        in (patch['replaceCities'] == true
                ? <dynamic>[]
                : existing['cities'] as List? ?? [])
            .cast<Map<String, dynamic>>()) {
      cities[identity(city)] = {...city};
    }
    for (final city
        in (patch['cities'] as List? ?? []).cast<Map<String, dynamic>>()) {
      final key = identity(city);
      final previous = cities[key] ?? <String, dynamic>{};
      final merged = <String, dynamic>{...previous, ...city};
      if ((merged['en'] as String?)?.trim().isNotEmpty != true) {
        throw FormatException('Missing canonical city name: ${entry.key}/$key');
      }
      if (merged['source'] == 'calculated' &&
          (merged['lat'] is! num || merged['lng'] is! num)) {
        throw FormatException(
          'Missing calculated coordinates: ${entry.key}/$key',
        );
      }
      cities[key] = merged;
    }
    result[entry.key] = {
      ...existing,
      ...patch,
      'cities': cities.values.toList()
        ..sort((a, b) => identity(a).compareTo(identity(b))),
    };
  }
  return result;
}
