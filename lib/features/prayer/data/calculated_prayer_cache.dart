import '../domain/entities/daily_prayer_times.dart';
import '../domain/prayer_time_zone.dart';
import 'adhan_calculation_source.dart';

/// 3-day rolling in-memory cache for calculated (adhan_dart) prayer times.
///
/// Mirrors [SqlitePrayerCache] structure but uses [AdhanCalculationSource]
/// instead of SQLite queries.
class CalculatedPrayerCache {
  final Map<String, DailyPrayerTimes> _map = {};
  String _cachedDateKey = '';

  bool get isNotEmpty => _map.isNotEmpty;

  bool isStale({String? timeZoneId, double? utcOffsetHours}) =>
      _dateKey(
        PrayerTimeZone.now(
          timeZoneId: timeZoneId,
          utcOffsetHours: utcOffsetHours,
        ),
      ) !=
      _cachedDateKey;

  DailyPrayerTimes? getToday({String? timeZoneId, double? utcOffsetHours}) =>
      _map[
        _dateKey(
          PrayerTimeZone.now(
            timeZoneId: timeZoneId,
            utcOffsetHours: utcOffsetHours,
          ),
        )
      ];

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
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    final newCache = <String, DailyPrayerTimes>{};
    final now = PrayerTimeZone.now(
      timeZoneId: timeZoneId,
      utcOffsetHours: utcOffsetHours,
    );
    for (var offset = 0; offset < 3; offset++) {
      final date = now.add(Duration(days: offset));
      final key = _dateKey(date);
      newCache[key] = source.calculateForDate(
        lat, lng, date, methodKey,
        madhabKey: madhabKey,
        timeZoneId: timeZoneId,
        utcOffsetHours: utcOffsetHours,
      );
    }
    _map
      ..clear()
      ..addAll(newCache);
    _cachedDateKey = _dateKey(now);
  }

  String _dateKey(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
