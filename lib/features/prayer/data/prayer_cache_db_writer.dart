import 'package:sqflite/sqflite.dart';

import '../domain/cancellation_token.dart';

/// Writes downloaded city rows into `prayer_cache.db` atomically.
///
/// Uses a single SQLite transaction: all [prayer_times] rows are inserted
/// first; [city_cache_meta] is written OUTSIDE this class by the caller
/// only after this method succeeds. A crash mid-write leaves no meta record →
/// the app re-downloads cleanly on next launch.
///
/// [CancellationToken] is checked between batches so a city-switch mid-write
/// rolls back via the thrown [CancellationException].
class PrayerCacheDbWriter {
  static const _batchSize = 100;

  Future<void> writeCityRows(
    Database db,
    int cityId,
    List<List<int>> rows,
    CancellationToken cancelToken,
  ) async {
    await db.transaction((txn) async {
      // Remove any partial data from a previous failed attempt.
      await txn.delete(
        'prayer_times',
        where: 'city_id = ?',
        whereArgs: [cityId],
      );
      await txn.delete(
        'city_cache_meta',
        where: 'city_id = ?',
        whereArgs: [cityId],
      );

      for (var i = 0; i < rows.length; i += _batchSize) {
        if (cancelToken.isCancelled) throw CancellationException();

        final end = (i + _batchSize).clamp(0, rows.length);
        final batch = txn.batch();
        for (final row in rows.sublist(i, end)) {
          batch.rawInsert(
            'INSERT OR REPLACE INTO prayer_times '
            '(city_id, date, fajr, sunrise, dhuhr, asr, maghrib, isha) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [cityId, row[0], row[1], row[2], row[3], row[4], row[5], row[6]],
          );
        }
        await batch.commit(noResult: true);
      }
    });
  }
}
