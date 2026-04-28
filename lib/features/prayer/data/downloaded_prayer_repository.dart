import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/entities/daily_prayer_times.dart';
import '../domain/i_prayer_times_repository.dart';
import '../domain/prayer_time_calculator.dart' as calc;
import 'sqlite_prayer_cache.dart';
import 'sqlite_prayer_queries.dart';

/// [IPrayerTimesRepository] backed by the writable `prayer_cache.db`.
///
/// Reuses [SqlitePrayerQueries] and [SqlitePrayerCache] unchanged — only the
/// [Database] instance differs (writable cache vs. bundled read-only DB).
class DownloadedPrayerRepository implements IPrayerTimesRepository {
  DownloadedPrayerRepository(this._db)
      : _queries = SqlitePrayerQueries(),
        _cache = SqlitePrayerCache();

  final Database _db;
  final SqlitePrayerQueries _queries;
  final SqlitePrayerCache _cache;

  String _activeCity = '';
  Map<String, int> _cityIds = {};
  List<String> _availableCities = const [];
  int _totalDays = 0;
  Future<void>? _refreshInFlight;

  @override
  bool get hasData => _cache.isNotEmpty;

  @override
  bool get isMultiCity => _cityIds.length > 1;

  @override
  List<String> get availableCities => _availableCities;

  @override
  String get activeCity => _activeCity;

  @override
  int get totalDays => _totalDays;

  /// Loads [countryKey] + sets [cityName] as active city and **awaits** the
  /// cache rebuild. Call this after a download completes so the data is ready
  /// before [CompositePrayerRepository.configureDatabaseMode] is called.
  Future<void> loadCity(String countryKey, String cityName) async {
    _cityIds = await _queries.fetchCityIds(_db, countryKey.toLowerCase());
    _availableCities = List.unmodifiable(_cityIds.keys.toList());
    _activeCity = _cityIds.containsKey(cityName)
        ? cityName
        : (_cityIds.isNotEmpty ? _cityIds.keys.first : '');
    _refreshInFlight = null;
    await _updateTotalDays();
    await _refreshCache();
  }

  @override
  Future<Either<Failure, Success>> initialize(String countryKey) =>
      loadCountry(countryKey);

  @override
  Future<Either<Failure, Success>> loadCountry(String countryKey) async {
    try {
      _cityIds = await _queries.fetchCityIds(_db, countryKey.toLowerCase());
      _availableCities = List.unmodifiable(_cityIds.keys.toList());
      if (!_cityIds.containsKey(_activeCity)) {
        _activeCity = _cityIds.isNotEmpty ? _cityIds.keys.first : '';
      }
      await _updateTotalDays();
      await _refreshCache();
      return const Right(Success());
    } catch (e) {
      return Left(CacheFailure('Failed to load country $countryKey: $e'));
    }
  }

  @override
  void setActiveCity(String city) {
    if (!_cityIds.containsKey(city)) return;
    _activeCity = city;
    _cache.invalidate();
    _refreshInFlight = null;
    _updateTotalDays();
    _refreshCache();
  }

  @override
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime date) async {
    try {
      if (_activeCity.isEmpty) return const Right(null);
      final cityId = _cityIds[_activeCity];
      if (cityId == null) return const Right(null);
      final key = calc.dateKey(date);
      final cached = _cache.getByKey(key);
      if (cached != null) return Right(cached);
      return Right(await _queries.fetchByKey(_db, cityId, key));
    } catch (e) {
      return Left(CacheFailure('Failed to fetch prayer times: $e'));
    }
  }

  @override
  DailyPrayerTimes? getToday() {
    if (_cache.isStale()) _refreshCache();
    return _cache.getToday();
  }

  @override
  DailyPrayerTimes? getTomorrowByKey(String key) => _cache.getByKey(key);

  @override
  void configureCalculatedMode(
    double lat,
    double lng,
    String methodKey, {
    String madhabKey = 'shafi',
    String cityLabel = '',
    String? timeZoneId,
    double? utcOffsetHours,
  }) {}

  @override
  void configureDatabaseMode() {}

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _refreshCache() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final future = _doRefreshCache();
    _refreshInFlight = future;
    return future;
  }

  Future<void> _doRefreshCache() async {
    try {
      if (_activeCity.isEmpty) return;
      final cityId = _cityIds[_activeCity];
      if (cityId == null) return;
      await _cache.refresh(_db, cityId, _queries);
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<void> _updateTotalDays() async {
    final cityId = _cityIds[_activeCity];
    if (cityId == null) return;
    _totalDays = await _queries.countDays(_db, cityId);
  }
}
