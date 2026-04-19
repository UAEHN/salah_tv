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
  // Cached once when _cityIds is populated; avoids allocating a new List on
  // every PrayerState snapshot (called at 1 Hz from the engine tick).
  List<String> _availableCities = const [];
  int _totalDays = 0;
  // Re-entry guard: fire-and-forget _refreshCache() is called every tick
  // while the cache is stale. Without this guard, repeated calls on slow
  // TV storage could pile up concurrent DB reads over hours.
  Future<void>? _refreshInFlight;

  // ── IPrayerTimesRepository getters ────────────────────────────────────────

  @override
  bool get hasData => _db != null && _cache.isNotEmpty;

  @override
  bool get isMultiCity => _cityIds.length > 1;

  @override
  List<String> get availableCities => _availableCities;

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
      await _ensureOpen();
      return loadCountry(countryKey);
    } catch (e) {
      return Left(CacheFailure('Failed to initialize prayer DB: $e'));
    }
  }

  /// Opens the DB without loading any country. Used at startup so the caller
  /// can enumerate the available countries via [fetchAllCountriesWithCities]
  /// before deciding which one to load.
  Future<Either<Failure, Success>> openOnly() async {
    try {
      await _ensureOpen();
      return const Right(Success());
    } catch (e) {
      return Left(CacheFailure('Failed to open prayer DB: $e'));
    }
  }

  Future<void> _ensureOpen() async {
    if (_db != null) return;
    await _initializer.copyIfNeeded();
    _db = await _initializer.openDb();
  }

  /// Returns every DB country mapped to its city names. Requires the DB to be
  /// open (call [openOnly] or [initialize] first).
  Future<Map<String, List<String>>> fetchAllCountriesWithCities() async {
    if (_db == null) return const {};
    return _queries.fetchAllCountriesWithCities(_db!);
  }

  /// Switches to [countryKey], reloads the city -> id map, refreshes cache.
  @override
  Future<Either<Failure, Success>> loadCountry(String countryKey) async {
    try {
      if (_db == null) return const Left(CacheFailure('DB not open'));
      // Normalize to lowercase: DB keys are stored lowercase ("uae", "egypt"),
      // but AppSettings.selectedCountry may arrive as "UAE", "Egypt", etc.
      _cityIds = await _queries.fetchCityIds(_db!, countryKey.toLowerCase());
      _availableCities = List.unmodifiable(_cityIds.keys.toList());

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
  /// No-op: SQLite repo does not support calculated mode.
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

  /// No-op: SQLite repo is always in database mode.
  @override
  void configureDatabaseMode() {}

  @override
  void setActiveCity(String city) {
    if (!_cityIds.containsKey(city)) return;
    _activeCity = city;
    // Invalidate immediately so getToday() returns null while the async
    // rebuild runs. The engine tick() null-retry picks up new data within
    // one second once _refreshCache() completes.
    _cache.invalidate();
    // Drop any in-flight refresh: it was reading the previous city's data
    // and would populate the cache with stale rows after invalidate().
    _refreshInFlight = null;
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

  Future<void> _refreshCache() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final future = _doRefreshCache();
    _refreshInFlight = future;
    return future;
  }

  Future<void> _doRefreshCache() async {
    try {
      if (_db == null || _activeCity.isEmpty) return;
      final cityId = _cityIds[_activeCity];
      if (cityId == null) return;
      await _cache.refresh(_db!, cityId, _queries);
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<void> _updateTotalDays() async {
    final cityId = _cityIds[_activeCity];
    if (_db == null || cityId == null) return;
    _totalDays = await _queries.countDays(_db!, cityId);
  }
}
