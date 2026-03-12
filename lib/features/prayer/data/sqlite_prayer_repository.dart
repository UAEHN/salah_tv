// Implements IPrayerTimesRepository using SQLite instead of an in-memory CSV cache.
// Drop-in replacement for CsvService — no other files need to change.
//
// Design: the interface has synchronous getToday() / getTomorrowByKey() methods.
// We satisfy these by keeping a tiny in-memory cache of only today + the next
// two days, pre-populated during initialize / loadCountry / setActiveCity.
// This gives O(1) synchronous lookups while only storing 3 rows in RAM
// (vs the full year that CsvService loaded).
//
// City names are stored in a lookup table; the repository holds a
// Map<String, int> (_cityIds) to translate name → integer id for queries.

import 'package:sqflite/sqflite.dart';
import '../domain/i_prayer_times_repository.dart';
import '../../../models/daily_prayer_times.dart';
import 'sqlite_db_initializer.dart';
import 'sqlite_prayer_queries.dart';

class SqlitePrayerRepository implements IPrayerTimesRepository {
  SqlitePrayerRepository({
    SqliteDbInitializer? initializer,
    SqlitePrayerQueries? queries,
  })  : _initializer = initializer ?? SqliteDbInitializer(),
        _queries = queries ?? SqlitePrayerQueries();

  final SqliteDbInitializer _initializer;
  final SqlitePrayerQueries _queries;

  Database? _db;
  String _activeCity = '';

  // city name → integer id mapping; populated by loadCountry().
  Map<String, int> _cityIds = {};

  // Tiny date cache: at most 3 entries (today + 2 days).
  // Refreshed by _refreshCache() on country/city change or date rollover.
  final Map<String, DailyPrayerTimes> _cache = {};
  String _cachedDateKey = '';

  int _totalDays = 0;

  // ── IPrayerTimesRepository getters ────────────────────────────────────────

  @override
  bool get hasData => _db != null && _cache.isNotEmpty;

  @override
  bool get isMultiCity => _cityIds.length > 1;

  @override
  List<String> get availableCities =>
      List.unmodifiable(_cityIds.keys.toList());

  @override
  String get activeCity => _activeCity;

  @override
  int get totalDays => _totalDays;

  // ── IPrayerTimesRepository methods ────────────────────────────────────────

  /// Copies the bundled DB to app storage on first run, opens the connection,
  /// then loads city data and pre-warms the date cache.
  @override
  Future<void> initialize(String countryKey) async {
    await _initializer.copyIfNeeded();
    _db = await _initializer.openDb();
    await loadCountry(countryKey);
  }

  /// Switches to [countryKey], reloads the city → id map, refreshes cache.
  @override
  Future<void> loadCountry(String countryKey) async {
    if (_db == null) return;
    // Normalize to lowercase — DB keys are stored as lowercase ("uae", "egypt"),
    // but AppSettings.selectedCountry may be saved as "UAE", "Egypt", etc.
    _cityIds = await _queries.fetchCityIds(_db!, countryKey.toLowerCase());

    // Keep current city if it exists in the new country; otherwise use first.
    if (!_cityIds.containsKey(_activeCity)) {
      _activeCity = _cityIds.isNotEmpty ? _cityIds.keys.first : '';
    }

    await _updateTotalDays();
    await _refreshCache();
  }

  /// Updates the active city and refreshes the cache for the new selection.
  @override
  void setActiveCity(String city) {
    if (!_cityIds.containsKey(city)) return;
    _activeCity = city;
    // Invalidate immediately so getToday() returns null while the async
    // rebuild runs. The engine's _tick() null-retry picks up the new data
    // within one second once _refreshCache() completes.
    _cache.clear();
    _cachedDateKey = '';
    _updateTotalDays();
    _refreshCache();
  }

  /// Returns today's times from the tiny cache.
  /// If the date has rolled past midnight, triggers a background refresh and
  /// returns null for one tick until the cache is rebuilt.
  @override
  DailyPrayerTimes? getToday() {
    final key = _todayKey();
    if (key != _cachedDateKey) _refreshCache(); // date changed — async rebuild
    return _cache[key];
  }

  /// Returns times for an arbitrary date key ("dd/MM/yyyy").
  /// Used by PrayerCycleEngine to look up tomorrow's times.
  @override
  DailyPrayerTimes? getTomorrowByKey(String key) => _cache[key];

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Fetches today and the next two days into the tiny cache.
  /// Three days covers midnight edge cases inside PrayerCycleEngine.
  Future<void> _refreshCache() async {
    if (_db == null || _activeCity.isEmpty) return;
    final cityId = _cityIds[_activeCity];
    if (cityId == null) return;

    // Build into a temporary map first, then do an atomic swap.
    // This ensures getToday() never sees an empty cache mid-rebuild.
    final newCache = <String, DailyPrayerTimes>{};
    final now = DateTime.now();
    for (int offset = 0; offset < 3; offset++) {
      final date = now.add(Duration(days: offset));
      final key = _dateKey(date);
      final entry = await _queries.fetchByKey(_db!, cityId, key);
      if (entry != null) newCache[key] = entry;
    }
    _cache
      ..clear()
      ..addAll(newCache);
    _cachedDateKey = _todayKey();
  }

  Future<void> _updateTotalDays() async {
    final cityId = _cityIds[_activeCity];
    if (_db == null || cityId == null) return;
    _totalDays = await _queries.countDays(_db!, cityId);
  }

  /// Formats [DateTime] to the "dd/MM/yyyy" cache key used across the app.
  String _dateKey(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _todayKey() => _dateKey(DateTime.now());
}
