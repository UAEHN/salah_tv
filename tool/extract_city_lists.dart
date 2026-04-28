// One-time tool: extracts country→cities mapping from the bundled SQLite DB
// and writes it to assets/db_city_lists.json.
//
// This JSON replaces the dynamic DB-based country/city discovery after the
// bundled prayer_times.db is removed from the app bundle.
//
// Usage: dart run tool/extract_city_lists.dart

import 'dart:io';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = p.absolute(p.join('assets', 'prayer_times.db'));
  final db = await openDatabase(dbPath, readOnly: true, singleInstance: false);

  final rows = await db.rawQuery('''
    SELECT co.key AS country_key, c.name AS city_name
    FROM   cities    c
    JOIN   countries co ON co.id = c.country_id
    WHERE  co.key != 'default'
    ORDER  BY co.key, c.name
  ''');

  final result = <String, List<String>>{};
  for (final r in rows) {
    final key  = r['country_key'] as String;
    final city = r['city_name']   as String;
    (result[key] ??= <String>[]).add(city);
  }

  await db.close();

  final output = const JsonEncoder.withIndent('  ').convert(result);
  File(p.join('assets', 'db_city_lists.json')).writeAsStringSync(output);

  var total = 0;
  result.forEach((k, v) {
    print('  $k: ${v.length} cities');
    total += v.length;
  });
  print('\nDone: ${result.length} countries, $total cities');
  print('Written to assets/db_city_lists.json');
}
