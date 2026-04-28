import 'package:sqflite/sqflite.dart';

/// SQL helpers for the writable `prayer_cache.db`.
///
/// Read operations (fetchByKey, fetchCityIds, countDays) are provided by
/// [SqlitePrayerQueries] which accepts any [Database] — no duplication needed.
/// This class handles only the write/meta operations specific to the cache DB.
class PrayerCacheDbQueries {
  /// Returns true if [cityName] in [countryKey] for [year] has a completed
  /// download record. Absence of [city_cache_meta] row means the city was
  /// never fully downloaded or the download crashed mid-write.
  Future<bool> isCityCached(
    Database db,
    String countryKey,
    String cityName,
    int year,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT m.year
      FROM   city_cache_meta m
      JOIN   cities    c  ON c.id  = m.city_id
      JOIN   countries co ON co.id = c.country_id
      WHERE  co.key = ? AND c.name = ? AND m.year = ?
      ''',
      [countryKey.toLowerCase(), cityName, year],
    );
    return rows.isNotEmpty;
  }

  /// Returns the stored hash for [cityId], or null if not cached.
  Future<String?> getCachedHash(Database db, int cityId) async {
    final rows = await db.query(
      'city_cache_meta',
      columns: ['hash'],
      where: 'city_id = ?',
      whereArgs: [cityId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['hash'] as String?;
  }

  /// Returns the city_id for the given country+city, or null if not stored.
  Future<int?> getCityId(
    Database db,
    String countryKey,
    String cityName,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT c.id
      FROM   cities    c
      JOIN   countries co ON co.id = c.country_id
      WHERE  co.key = ? AND c.name = ?
      ''',
      [countryKey.toLowerCase(), cityName],
    );
    return rows.isEmpty ? null : rows.first['id'] as int?;
  }

  /// Inserts or ignores country row; returns its id.
  Future<int> upsertCountry(Database db, String key) async {
    final lower = key.toLowerCase();
    await db.execute(
      'INSERT OR IGNORE INTO countries (key) VALUES (?)',
      [lower],
    );
    final rows = await db.rawQuery(
      'SELECT id FROM countries WHERE key = ?',
      [lower],
    );
    return rows.first['id'] as int;
  }

  /// Inserts or ignores city row; returns its id.
  Future<int> upsertCity(Database db, int countryId, String name) async {
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

  /// Records a successful download. Called ONLY after all prayer_times rows
  /// have been committed — guarantees [isCityCached] returns false on crash.
  Future<void> markCityCached(
    Database db,
    int cityId,
    int year,
    String hash,
  ) async {
    await db.execute(
      'INSERT OR REPLACE INTO city_cache_meta '
      '(city_id, year, hash, fetched_at) VALUES (?, ?, ?, ?)',
      [cityId, year, hash, DateTime.now().millisecondsSinceEpoch],
    );
  }

  /// Returns the most recently cached (countryKey, cityName), or null if DB empty.
  Future<({String countryKey, String cityName})?> getLastCachedCity(
    Database db,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT co.key AS countryKey, c.name AS cityName
      FROM   city_cache_meta m
      JOIN   cities    c  ON c.id  = m.city_id
      JOIN   countries co ON co.id = c.country_id
      ORDER  BY m.fetched_at DESC
      LIMIT  1
      ''',
    );
    if (rows.isEmpty) return null;
    return (
      countryKey: rows.first['countryKey'] as String,
      cityName: rows.first['cityName'] as String,
    );
  }

  /// Removes all prayer_times rows and the meta record for [cityId].
  /// Called before writing new data to clean up any previous partial download.
  Future<void> deleteCityData(Database db, int cityId) async {
    await db.delete(
      'prayer_times',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
    await db.delete(
      'city_cache_meta',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
  }
}
