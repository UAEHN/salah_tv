// Build-time script — converts all CSV prayer-time files into a compact SQLite DB.
//
// Usage:  dart run tool/csv_to_sqlite.dart
//
// Input:  assets/csv/*.csv  (16 files, single-city + multi-city formats)
// Output: assets/prayer_times.db
//
// Safe to re-run: drops and recreates all tables each time.
//
// Schema uses integer types throughout to minimize file size:
//   countries(id, key)                  — e.g. id=1, key="uae"
//   cities(id, country_id, name)        — e.g. id=5, country_id=1, name="Dubai"
//   prayer_times(city_id, date, fajr, sunrise, dhuhr, asr, maghrib, isha)
//     date: YYYYMMDD integer (e.g. 20260311)
//     fajr..isha: minutes-since-midnight integer (e.g. 05:12 → 312)
//
// Country key is derived from the filename:
//   "uae_prayer_times_2026.csv" → "uae"
//   "prayer_times.csv" (fallback)  → "default"

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

const _csvFiles = [
  'prayer_times.csv',
  'uae_prayer_times_2026.csv',
  'oman_prayer_times_2026.csv',
  'saudi_prayer_times_2026.csv',
  'kuwait_prayer_times_2026.csv',
  'qatar_prayer_times_2026.csv',
  'bahrain_prayer_times_2026.csv',
  'egypt_prayer_times_2026.csv',
  'iraq_prayer_times_2026.csv',
  'jordan_prayer_times_2026.csv',
  'lebanon_prayer_times_2026.csv',
  'morocco_prayer_times_2026.csv',
  'palestine_prayer_times_2026.csv',
  'syria_prayer_times_2026.csv',
  'tunisia_prayer_times_2026.csv',
  'yemen_prayer_times_2026.csv',
];

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = p.absolute(p.join('assets', 'prayer_times.db'));
  final dbFile = File(dbPath);
  if (dbFile.existsSync()) dbFile.deleteSync();

  final db = await openDatabase(dbPath, singleInstance: false);

  // Tune SQLite for bulk insert performance.
  await db.execute('PRAGMA journal_mode = OFF');
  await db.execute('PRAGMA synchronous  = OFF');
  await db.execute('PRAGMA page_size    = 4096');

  await _createSchema(db);

  int totalRows = 0;
  for (final fileName in _csvFiles) {
    final file = File(p.join('assets', 'csv', fileName));
    if (!file.existsSync()) {
      print('  SKIP  $fileName (not found)');
      continue;
    }
    final countryKey = _deriveCountryKey(fileName);
    final countryId = await _upsertCountry(db, countryKey);
    final rows = await _importCsv(db, file, countryId);
    totalRows += rows;
    print('  OK    $fileName → $rows rows  (country: $countryKey)');
  }

  // Compact the DB after all inserts.
  await db.execute('VACUUM');
  await db.close();

  final sizeKb = File(dbPath).lengthSync() ~/ 1024;
  print('\nDone: $totalRows total rows → $sizeKb KB');
}

// ── Schema ────────────────────────────────────────────────────────────────────

Future<void> _createSchema(Database db) async {
  // Countries lookup: maps short key string → integer id.
  await db.execute('''
    CREATE TABLE countries (
      id  INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT    NOT NULL UNIQUE
    )
  ''');

  // Cities lookup: maps (country_id, city_name) → integer id.
  await db.execute('''
    CREATE TABLE cities (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      country_id INTEGER NOT NULL,
      name       TEXT    NOT NULL,
      UNIQUE (country_id, name)
    )
  ''');

  // Prayer times: all integers for compact storage.
  // date    = YYYYMMDD  (e.g. 20260311)
  // fajr..isha = minutes since midnight  (e.g. 05:12 → 312)
  await db.execute('''
    CREATE TABLE prayer_times (
      city_id INTEGER NOT NULL,
      date    INTEGER NOT NULL,
      fajr    INTEGER NOT NULL,
      sunrise INTEGER NOT NULL,
      dhuhr   INTEGER NOT NULL,
      asr     INTEGER NOT NULL,
      maghrib INTEGER NOT NULL,
      isha    INTEGER NOT NULL,
      PRIMARY KEY (city_id, date)
    )
  ''');

  // Index for the most common lookup: city_id + date.
  await db.execute(
    'CREATE INDEX idx_city_date ON prayer_times (city_id, date)',
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Inserts or ignores the country row and returns its id.
Future<int> _upsertCountry(Database db, String key) async {
  await db.execute(
    'INSERT OR IGNORE INTO countries (key) VALUES (?)',
    [key],
  );
  final rows = await db.rawQuery(
    'SELECT id FROM countries WHERE key = ?',
    [key],
  );
  return rows.first['id'] as int;
}

/// Inserts or ignores the city row and returns its id.
Future<int> _upsertCity(Database db, int countryId, String name) async {
  await db.execute(
    'INSERT OR IGNORE INTO cities (country_id, name) VALUES (?, ?)',
    [countryId, name],
  );
  final rows = await db.rawQuery(
    'SELECT id FROM cities WHERE country_id = ? AND name = ?',
    [countryId, name],
  );
  return rows.first['id'] as int;
}

/// Derives the country key from the CSV filename.
/// "uae_prayer_times_2026.csv" → "uae" / "prayer_times.csv" → "default"
String _deriveCountryKey(String fileName) {
  if (fileName == 'prayer_times.csv') return 'default';
  return fileName.replaceAll(RegExp(r'_prayer_times_\d+\.csv$'), '');
}

/// Parses "dd/MM/yyyy" → YYYYMMDD integer (e.g. "11/03/2026" → 20260311).
int _dateToInt(String s) {
  final p = s.split('/');
  return int.parse(p[2]) * 10000 + int.parse(p[1]) * 100 + int.parse(p[0]);
}

/// Parses "HH:MM" → minutes since midnight (e.g. "05:12" → 312).
int _timeToInt(String s) {
  final p = s.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// Imports a single CSV into the DB. Returns the number of rows inserted.
Future<int> _importCsv(Database db, File file, int countryId) async {
  final lines = file.readAsLinesSync();
  if (lines.isEmpty) return 0;

  final isMultiCity = lines.first.trim().toLowerCase().startsWith('city,');

  // Pre-populate city id cache to avoid repeated SELECT per row.
  final Map<String, int> cityIdCache = {};

  int count = 0;
  final batch = db.batch();

  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final cols = line.split(',');

    // 8 columns for multi-city, 7 for single-city.
    final minCols = isMultiCity ? 8 : 7;
    if (cols.length < minCols) continue;

    // Column offset: multi-city has city at col 0, date at col 1.
    final offset = isMultiCity ? 1 : 0;
    final cityName = isMultiCity ? cols[0].trim() : 'Dubai';

    // Resolve city_id (cache to avoid DB round-trips per row).
    if (!cityIdCache.containsKey(cityName)) {
      cityIdCache[cityName] = await _upsertCity(db, countryId, cityName);
    }
    final cityId = cityIdCache[cityName]!;

    batch.rawInsert(
      'INSERT OR REPLACE INTO prayer_times '
      '(city_id, date, fajr, sunrise, dhuhr, asr, maghrib, isha) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        cityId,
        _dateToInt(cols[0 + offset].trim()),
        _timeToInt(cols[1 + offset].trim()),
        _timeToInt(cols[2 + offset].trim()),
        _timeToInt(cols[3 + offset].trim()),
        _timeToInt(cols[4 + offset].trim()),
        _timeToInt(cols[5 + offset].trim()),
        _timeToInt(cols[6 + offset].trim()),
      ],
    );
    count++;
  }

  await batch.commit(noResult: true);
  return count;
}
