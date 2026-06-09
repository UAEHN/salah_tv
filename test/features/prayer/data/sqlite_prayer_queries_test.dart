import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ghasaq/features/prayer/data/sqlite_prayer_queries.dart';

/// Focused tests for the year-agnostic fallback in [SqlitePrayerQueries.fetchByKey].
///
/// The published prayer table is stored for a single calendar year (2026).
/// Times repeat within ~1 minute year-to-year, so a lookup for a later year
/// must reuse the stored year's same month/day — built on the *requested*
/// date — so the prayer cycle never stops once the device passes the data year.
void main() {
  late Database db;
  final q = SqlitePrayerQueries();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
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
    // Algiers 2026: 1 Jan (388=06:28) and 28 Feb (for the leap-day fallback).
    await db.insert('prayer_times', {
      'city_id': 1, 'date': 20260101,
      'fajr': 388, 'sunrise': 481, 'dhuhr': 772,
      'asr': 925, 'maghrib': 1066, 'isha': 1150,
    });
    await db.insert('prayer_times', {
      'city_id': 1, 'date': 20260228,
      'fajr': 372, 'sunrise': 459, 'dhuhr': 773,
      'asr': 944, 'maghrib': 1090, 'isha': 1170,
    });
  });

  tearDown(() async => db.close());

  test('exact year match returns the stored row on its own date', () async {
    final r = await q.fetchByKey(db, 1, '01/01/2026');
    expect(r, isNotNull);
    expect(r!.date, DateTime(2026, 1, 1));
    expect(r.fajr, DateTime(2026, 1, 1, 6, 28)); // 388 min
    expect(r.isha, DateTime(2026, 1, 1, 19, 10)); // 1150 min
  });

  test('future year reuses same month/day, rebuilt on the requested date',
      () async {
    final r = await q.fetchByKey(db, 1, '01/01/2030');
    expect(r, isNotNull);
    // Times must land on the LOOKED-UP day, not the stored 2026 day.
    expect(r!.date, DateTime(2030, 1, 1));
    expect(r.fajr, DateTime(2030, 1, 1, 6, 28)); // same minutes as 2026
    expect(r.isha, DateTime(2030, 1, 1, 19, 10));
  });

  test('29 Feb falls back to 28 Feb when the data year is not a leap year',
      () async {
    final r = await q.fetchByKey(db, 1, '29/02/2028');
    expect(r, isNotNull);
    expect(r!.date, DateTime(2028, 2, 29));
    expect(r.fajr, DateTime(2028, 2, 29, 6, 12)); // 372 min from 28 Feb row
  });

  test('a month/day with no stored row returns null', () async {
    final r = await q.fetchByKey(db, 1, '15/07/2030');
    expect(r, isNull);
  });
}
