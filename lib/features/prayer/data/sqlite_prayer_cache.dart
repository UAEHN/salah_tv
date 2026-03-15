import 'package:sqflite/sqflite.dart';
import '../domain/entities/daily_prayer_times.dart';
import 'sqlite_prayer_queries.dart';

/// 3-day rolling in-memory cache (today + 2 days) for O(1) lookups.
/// Rebuilt atomically on city/country change or date rollover.
class SqlitePrayerCache {
  final Map<String, DailyPrayerTimes> _map = {};
  String _cachedDateKey = '';

  bool get isNotEmpty => _map.isNotEmpty;

  /// True when the current date has rolled past the last rebuild.
  bool isStale() => _dateKey(DateTime.now()) != _cachedDateKey;

  DailyPrayerTimes? getToday() => _map[_dateKey(DateTime.now())];

  DailyPrayerTimes? getByKey(String key) => _map[key];

  /// Clears all entries immediately (call before async rebuild).
  void invalidate() {
    _map.clear();
    _cachedDateKey = '';
  }

  /// Fetches today and the next two days into the cache atomically.
  /// Three days covers midnight edge cases inside PrayerCycleEngine.
  Future<void> refresh(
    Database db,
    int cityId,
    SqlitePrayerQueries queries,
  ) async {
    final newCache = <String, DailyPrayerTimes>{};
    final now = DateTime.now();
    for (var offset = 0; offset < 3; offset++) {
      final date = now.add(Duration(days: offset));
      final key = _dateKey(date);
      final entry = await queries.fetchByKey(db, cityId, key);
      if (entry != null) newCache[key] = entry;
    }
    _map
      ..clear()
      ..addAll(newCache);
    _cachedDateKey = _dateKey(DateTime.now());
  }

  String _dateKey(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
