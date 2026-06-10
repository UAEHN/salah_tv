import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens (or creates) the writable `prayer_cache.db` that stores downloaded
/// city prayer times. Starts empty — no asset copy needed.
///
/// Schema mirrors the bundled DB schema (countries/cities/prayer_times/index)
/// plus [city_cache_meta] which tracks download status per city.
/// Absence of a [city_cache_meta] row means the download never completed
/// (crash-safe: the app re-downloads cleanly on next launch).
class PrayerCacheDbInitializer {
  static const _dbFileName = 'prayer_cache.db';
  static const _dbVersion = 1;

  Future<Database> openOrCreate() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbFileName);
    return openDatabase(path, version: _dbVersion, onCreate: _createSchema);
  }

  Future<void> createSchemaForTest(Database db) => _createSchema(db, 1);

  Future<void> _createSchema(Database db, int _) async {
    await db.execute('''
      CREATE TABLE countries (
        id  INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT    NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE cities (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        country_id INTEGER NOT NULL,
        name       TEXT    NOT NULL,
        UNIQUE (country_id, name)
      )
    ''');
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
    await db.execute(
      'CREATE INDEX idx_city_date ON prayer_times (city_id, date)',
    );
    // Written LAST after prayer_times rows are committed.
    // Its absence signals an incomplete download → triggers re-download.
    await db.execute('''
      CREATE TABLE city_cache_meta (
        city_id    INTEGER PRIMARY KEY,
        year       INTEGER NOT NULL,
        hash       TEXT    NOT NULL,
        fetched_at INTEGER NOT NULL
      )
    ''');
  }
}
