// SQLite-backed IPrayerTimesRepository.
// City names are mapped name -> integer id via SqlitePrayerQueries.
// Cache logic lives in SqlitePrayerCache (3-day rolling window).

import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/i_prayer_times_repository.dart';
import '../domain/entities/daily_prayer_times.dart';
import '../domain/prayer_time_calculator.dart' as calc;
import 'sqlite_db_initializer.dart';
import 'sqlite_prayer_queries.dart';
import 'sqlite_prayer_cache.dart';

class SqlitePrayerRepository implements IPrayerTimesRepository {
  SqlitePrayerRepository({
    SqliteDbInitializer? initializer,
    SqlitePrayerQueries? queries,
  }) : _initializer = initializer ?? SqliteDbInitializer(),
       _queries = queries ?? SqlitePrayerQueries();

  final SqliteDbInitializer _initializer;
  final SqlitePrayerQueries _queries;
  final SqlitePrayerCache _cache = SqlitePrayerCache();

  Database? _db;
  String _activeCity = '';
  Map<String, int> _cityIds = {};
  int _totalDays = 0;

  // ── IPrayerTimesRepository getters ────────────────────────────────────────

  @override
  bool get hasData => _db != null && _cache.isNotEmpty;

  @override
  bool get isMultiCity => _cityIds.length > 1;

  @override
  List<String> get availableCities => List.unmodifiable(_cityIds.keys.toList());

  @override
  String get activeCity => _activeCity;

  @override
  int get totalDays => _totalDays;

  // ── IPrayerTimesRepository methods ────────────────────────────────────────

  /// Copies the bundled DB to app storage on first run, opens the connection,
  /// then loads city data and pre-warms the date cache.
  @override
  Future<Either<Failure, Success>> initialize(String countryKey) async {
    try {
      await _initializer.copyIfNeeded();
      _db = await _initializer.openDb();
      return loadCountry(countryKey);
    } catch (e) {
      return Left(CacheFailure('Failed to initialize prayer DB: $e'));
    }
  }

  /// Switches to [countryKey], reloads the city -> id map, refreshes cache.
  @override
  Future<Either<Failure, Success>> loadCountry(String countryKey) async {
    try {
      if (_db == null) return const Left(CacheFailure('DB not open'));
      // Normalize to lowercase: DB keys are stored lowercase ("uae", "egypt"),
      // but AppSettings.selectedCountry may arrive as "UAE", "Egypt", etc.
      _cityIds = await _queries.fetchCityIds(_db!, countryKey.toLowerCase());

      // Keep current city if it exists in the new country; otherwise use first.
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

  /// Updates the active city and refreshes the cache for the new selection.
  @override
  void setActiveCity(String city) {
    if (!_cityIds.containsKey(city)) return;
    _activeCity = city;
    // Invalidate immediately so getToday() returns null while the async
    // rebuild runs. The engine tick() null-retry picks up new data within
    // one second once _refreshCache() completes.
    _cache.invalidate();
    _updateTotalDays();
    _refreshCache();
  }

  @override
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime date) async {
    try {
      if (_db == null || _activeCity.isEmpty) return const Right(null);
      final cityId = _cityIds[_activeCity];
      if (cityId == null) return const Right(null);
      final key = calc.dateKey(date);
      final cached = _cache.getByKey(key);
      if (cached != null) return Right(cached);
      final entry = await _queries.fetchByKey(_db!, cityId, key);
      return Right(entry);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch prayer times for date: $e'));
    }
  }

  /// Returns today's times from the rolling cache.
  /// If the date has rolled past midnight, triggers a background refresh and
  /// returns null for one tick until the cache is rebuilt.
  @override
  DailyPrayerTimes? getToday() {
    if (_cache.isStale()) _refreshCache();
    return _cache.getToday();
  }

  /// Returns times for an arbitrary date key ("dd/MM/yyyy").
  /// Used by PrayerCycleEngine to look up tomorrow's times.
  @override
  DailyPrayerTimes? getTomorrowByKey(String key) => _cache.getByKey(key);

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _refreshCache() async {
    if (_db == null || _activeCity.isEmpty) return;
    final cityId = _cityIds[_activeCity];
    if (cityId == null) return;
    await _cache.refresh(_db!, cityId, _queries);
  }

  Future<void> _updateTotalDays() async {
    final cityId = _cityIds[_activeCity];
    if (_db == null || cityId == null) return;
    _totalDays = await _queries.countDays(_db!, cityId);
  }
}
