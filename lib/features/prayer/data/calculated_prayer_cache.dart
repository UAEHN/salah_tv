import '../domain/entities/daily_prayer_times.dart';
import 'adhan_calculation_source.dart';

/// 3-day rolling in-memory cache for calculated (adhan_dart) prayer times.
///
/// Mirrors [SqlitePrayerCache] structure but uses [AdhanCalculationSource]
/// instead of SQLite queries.
class CalculatedPrayerCache {
  final Map<String, DailyPrayerTimes> _map = {};
  String _cachedDateKey = '';

  bool get isNotEmpty => _map.isNotEmpty;

  bool isStale() => _dateKey(DateTime.now()) != _cachedDateKey;

  DailyPrayerTimes? getToday() => _map[_dateKey(DateTime.now())];

  DailyPrayerTimes? getByKey(String key) => _map[key];

  void invalidate() {
    _map.clear();
    _cachedDateKey = '';
  }

  /// Recalculates today and the next two days into the cache.
  void refresh(
    AdhanCalculationSource source,
    double lat,
    double lng,
    String methodKey, {
    String madhabKey = 'shafi',
    double? utcOffsetHours,
  }) {
    final newCache = <String, DailyPrayerTimes>{};
    final now = DateTime.now();
    for (var offset = 0; offset < 3; offset++) {
      final date = now.add(Duration(days: offset));
      final key = _dateKey(date);
      newCache[key] = source.calculateForDate(
        lat, lng, date, methodKey,
        madhabKey: madhabKey,
        utcOffsetHours: utcOffsetHours,
      );
    }
    _map
      ..clear()
      ..addAll(newCache);
    _cachedDateKey = _dateKey(DateTime.now());
  }

  String _dateKey(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
