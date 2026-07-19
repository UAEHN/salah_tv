import 'package:sqflite/sqflite.dart';
import '../../../core/app_config.dart';
import '../domain/entities/daily_prayer_times.dart';
import 'sqlite_prayer_queries.dart';

/// Rolling in-memory cache (AppConfig.prayerScheduleDays days) for O(1) lookups.
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

  /// Fetches today + the next (AppConfig.prayerScheduleDays - 1) days atomically.
  /// Covers the notification horizon and the cycle's midnight edge cases.
  Future<void> refresh(
    Database db,
    int cityId,
    SqlitePrayerQueries queries,
  ) async {
    final newCache = <String, DailyPrayerTimes>{};
    final now = DateTime.now();
    for (var offset = 0; offset < AppConfig.prayerScheduleDays; offset++) {
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
