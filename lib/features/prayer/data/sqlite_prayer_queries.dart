// All SQL queries for the prayer_times DB — kept in one place so schema
// changes only touch this file.
//
// Schema (integer-first for compact storage):
//   countries(id, key)              — e.g. key = "uae"
//   cities(id, country_id, name)    — city name stored once; referenced by id
//   prayer_times(city_id, date, fajr, sunrise, dhuhr, asr, maghrib, isha)
//     date:      YYYYMMDD integer   (e.g. 20260311)
//     fajr..isha: minutes-since-midnight integer (e.g. 05:12 → 312)
//
// Date keys throughout the app use "dd/MM/yyyy" strings (Issue 12).
// Conversion helpers _dateKeyToInt / _intToDateTime handle the bridge.

import 'package:sqflite/sqflite.dart';
import '../domain/entities/daily_prayer_times.dart';

class SqlitePrayerQueries {
  // ── City / country lookups ────────────────────────────────────────────────

  /// Returns every DB country mapped to its sorted list of city names.
  /// Called once at startup so the UI can discover countries from the DB
  /// itself — no hard-coded list, no drift between DB and JSON.
  Future<Map<String, List<String>>> fetchAllCountriesWithCities(
    Database db,
  ) async {
    final rows = await db.rawQuery('''
      SELECT co.key AS country_key, c.name AS city_name
      FROM   cities    c
      JOIN   countries co ON co.id = c.country_id
      WHERE  co.key != 'default'
      ORDER  BY co.key, c.name
    ''');
    final result = <String, List<String>>{};
    for (final r in rows) {
      final key = r['country_key'] as String;
      (result[key] ??= <String>[]).add(r['city_name'] as String);
    }
    return result;
  }

  /// Returns all cities for [countryKey] as a map of name → city_id.
  /// Called once per country switch; result is held in the repository.
  Future<Map<String, int>> fetchCityIds(Database db, String countryKey) async {
    final rows = await db.rawQuery(
      '''
      SELECT c.id, c.name
      FROM   cities    c
      JOIN   countries co ON co.id = c.country_id
      WHERE  co.key = ?
      ORDER  BY c.name
      ''',
      [countryKey],
    );
    return {for (final r in rows) r['name'] as String: r['id'] as int};
  }

  // ── Prayer time queries ───────────────────────────────────────────────────

  /// Returns prayer times for [cityId] on the date represented by [dateKey].
  /// [dateKey] must be "dd/MM/yyyy". Returns null if not found.
  /// Called by getToday() / getTomorrowByKey() — index on (city_id, date) is O(log n).
  Future<DailyPrayerTimes?> fetchByKey(
    Database db,
    int cityId,
    String dateKey,
  ) async {
    final dateInt = _dateKeyToInt(dateKey);
    var rows = await db.query(
      'prayer_times',
      where: 'city_id = ? AND date = ?',
      whereArgs: [cityId, dateInt],
      limit: 1,
    );
    if (rows.isEmpty) {
      // Year-agnostic fallback: prayer times for a given month/day repeat
      // within ~1 minute year-to-year, so when the requested year has no
      // stored data (e.g. the published table is 2026 and the device is in
      // 2027+), reuse the stored year's same month/day instead of returning
      // null and stalling the cycle. _rowToModel rebuilds the times on the
      // *requested* date so they land on the correct calendar day.
      final mmdd = dateInt % 10000; // MMDD part (e.g. 20270101 → 101)
      rows = await db.query(
        'prayer_times',
        where: 'city_id = ? AND date % 10000 = ?',
        whereArgs: [cityId, mmdd],
        limit: 1,
      );
      if (rows.isEmpty && mmdd == 229) {
        // 29 Feb requested but the stored year is not a leap year → use 28 Feb.
        rows = await db.query(
          'prayer_times',
          where: 'city_id = ? AND date % 10000 = ?',
          whereArgs: [cityId, 228],
          limit: 1,
        );
      }
      if (rows.isEmpty) return null;
    }
    return _rowToModel(rows.first, dateKey);
  }

  /// Returns the total number of days stored for [cityId].
  /// Satisfies IPrayerTimesRepository.totalDays.
  Future<int> countDays(Database db, int cityId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM prayer_times WHERE city_id = ?',
      [cityId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ── Date conversion ───────────────────────────────────────────────────────

  /// Converts "dd/MM/yyyy" cache key → YYYYMMDD integer stored in the DB.
  /// e.g. "11/03/2026" → 20260311
  int _dateKeyToInt(String key) {
    final p = key.split('/');
    return int.parse(p[2]) * 10000 + int.parse(p[1]) * 100 + int.parse(p[0]);
  }

  /// Converts "dd/MM/yyyy" cache key → DateTime.
  /// Used so the model is built on the *requested* date (supports the
  /// year-agnostic fallback in [fetchByKey], where the stored row is from a
  /// different year than the one being looked up).
  DateTime _dateKeyToDate(String key) {
    final p = key.split('/');
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  // ── Row mapping ───────────────────────────────────────────────────────────

  /// Maps a raw DB row (integer columns) to [DailyPrayerTimes].
  /// [dateKey] is the "dd/MM/yyyy" string used as a lookup key by the engine.
  DailyPrayerTimes _rowToModel(Map<String, Object?> row, String dateKey) {
    // Build on the *requested* date (from dateKey), not the stored row's year.
    // For an exact match these are identical; for the year-agnostic fallback
    // in [fetchByKey] this places the stored times on the looked-up calendar
    // day so the cycle keeps working past the data year.
    final date = _dateKeyToDate(dateKey);
    return DailyPrayerTimes(
      date: date,
      fajr: _minutesToTime(date, row['fajr'] as int),
      sunrise: _minutesToTime(date, row['sunrise'] as int),
      dhuhr: _minutesToTime(date, row['dhuhr'] as int),
      asr: _minutesToTime(date, row['asr'] as int),
      maghrib: _minutesToTime(date, row['maghrib'] as int),
      isha: _minutesToTime(date, row['isha'] as int),
    );
  }

  /// Converts minutes-since-midnight integer back to a full [DateTime].
  /// e.g. date=2026-03-11, minutes=312 → DateTime(2026, 3, 11, 5, 12)
  DateTime _minutesToTime(DateTime date, int minutes) =>
      DateTime(date.year, date.month, date.day, minutes ~/ 60, minutes % 60);
}
