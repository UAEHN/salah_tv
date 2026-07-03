import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the single source of truth for country translations
/// (assets/countries.json) against drift and gaps. If this fails, a country
/// would render untranslated or a DB city list would lose its label.
void main() {
  final countries =
      (jsonDecode(File('assets/countries.json').readAsStringSync())
              as Map<String, dynamic>)['countries']
          as Map<String, dynamic>;

  test('every country has non-empty Arabic and English names', () {
    for (final entry in countries.entries) {
      final iso = entry.key;
      final m = entry.value as Map<String, dynamic>;
      expect(
        RegExp(r'^[A-Z]{2}$').hasMatch(iso),
        isTrue,
        reason: 'bad ISO $iso',
      );
      expect(
        (m['ar'] as String?)?.trim().isNotEmpty,
        isTrue,
        reason: 'ar $iso',
      );
      expect(
        (m['en'] as String?)?.trim().isNotEmpty,
        isTrue,
        reason: 'en $iso',
      );
    }
  });

  test('dbKeys are lowercase and unique', () {
    final seen = <String>{};
    for (final v in countries.values) {
      final dbKey = (v as Map<String, dynamic>)['dbKey'] as String?;
      if (dbKey == null) continue;
      expect(dbKey, dbKey.toLowerCase());
      expect(seen.add(dbKey), isTrue, reason: 'duplicate dbKey $dbKey');
    }
  });

  test('every bundled DB country has a matching countries.json entry', () {
    final dbKeysInCatalog = {
      for (final v in countries.values)
        if ((v as Map<String, dynamic>)['dbKey'] != null) v['dbKey'] as String,
    };
    final cityLists =
        jsonDecode(File('assets/db_city_lists.json').readAsStringSync())
            as Map<String, dynamic>;
    for (final dbKey in cityLists.keys) {
      expect(
        dbKeysInCatalog.contains(dbKey),
        isTrue,
        reason: 'DB country "$dbKey" is missing from countries.json',
      );
    }
  });

  test('legacy files no longer carry a countries section', () {
    final db =
        jsonDecode(File('assets/db_countries.json').readAsStringSync())
            as Map<String, dynamic>;
    final world =
        jsonDecode(File('assets/world_cities.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(db.containsKey('countries'), isFalse);
    expect(world.containsKey('countries'), isFalse);
  });
}
