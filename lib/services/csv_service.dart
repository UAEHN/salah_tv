import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_prayer_times.dart';

class CsvService {
  static final CsvService _instance = CsvService._internal();
  factory CsvService() => _instance;
  CsvService._internal();

  // Active cache — always points to the current city's data
  Map<String, DailyPrayerTimes> _cache = {};

  // Multi-city support
  bool _isMultiCity = false;
  final Map<String, Map<String, DailyPrayerTimes>> _cityCache = {};
  String _activeCity = 'Dubai';
  List<String> _availableCities = [];

  static const _countryAssets = [
    'assets/csv/uae_prayer_times_2026.csv',
    'assets/csv/oman_prayer_times_2026.csv',
    'assets/csv/saudi_prayer_times_2026.csv',
    'assets/csv/kuwait_prayer_times_2026.csv',
    'assets/csv/qatar_prayer_times_2026.csv',
    'assets/csv/bahrain_prayer_times_2026.csv',
    'assets/csv/egypt_prayer_times_2026.csv',
    'assets/csv/iraq_prayer_times_2026.csv',
    'assets/csv/jordan_prayer_times_2026.csv',
    'assets/csv/lebanon_prayer_times_2026.csv',
    'assets/csv/morocco_prayer_times_2026.csv',
    'assets/csv/palestine_prayer_times_2026.csv',
    'assets/csv/syria_prayer_times_2026.csv',
    'assets/csv/tunisia_prayer_times_2026.csv',
    'assets/csv/yemen_prayer_times_2026.csv',
  ];
  static const _fallbackAssetPath = 'assets/csv/prayer_times.csv';
  static const _savedFileName = 'prayer_times_custom.csv';

  bool get hasData => _cache.isNotEmpty;
  bool get isMultiCity => _isMultiCity;
  List<String> get availableCities => List.unmodifiable(_availableCities);
  String get activeCity => _activeCity;
  int get totalDays => _cache.length;

  Future<void> initialize(String countryKey) async {
    try {
      await _loadCountryAsset(countryKey);
    } catch (_) {
      try {
        await _loadFromFallback();
      } catch (_) {}
    }
  }

  /// Load a specific country's CSV dynamically
  Future<void> loadCountry(String countryKey) async {
    await _loadCountryAsset(countryKey);
  }

  /// Switch the active city (only effective when [isMultiCity] is true).
  void setActiveCity(String city) {
    if (!_isMultiCity) return;
    final data = _cityCache[city];
    if (data != null) {
      _activeCity = city;
      _cache = data;
    }
  }

  Future<void> _loadCountryAsset(String countryKey) async {
    final assetName =
        'assets/csv/${countryKey.toLowerCase()}_prayer_times_2026.csv';
    try {
      final content = await rootBundle.loadString(assetName);
      _parseContent(content);
    } catch (_) {
      // Fallback if not found
      await _loadFromFallback();
    }
  }

  Future<void> _loadFromFallback() async {
    final content = await rootBundle.loadString(_fallbackAssetPath);
    _parseContent(content);
  }

  Future<void> _loadFromFile(File file) async {
    final content = await file.readAsString();
    _parseContent(content);
  }

  void _parseContent(String content) {
    _cache = {};
    _cityCache.clear();
    _isMultiCity = false;
    _availableCities = [];

    final lines = content.split('\n');
    if (lines.isEmpty) return;

    // Detect format: multi-city CSV starts with "City," header
    final header = lines[0].trim().toLowerCase();
    if (header.startsWith('city,')) {
      _parseMultiCity(lines);
    } else {
      _parseSingleCity(lines);
    }
  }

  void _parseSingleCity(List<String> lines) {
    for (int i = 1; i < lines.length; i++) {
      final result = _parseLine(lines[i].trim(), cityOffset: 0);
      if (result != null) _cache[result.$1] = result.$2;
    }
  }

  void _parseMultiCity(List<String> lines) {
    _isMultiCity = true;
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = line.split(',');
      if (parts.length < 8) continue;
      final city = parts[0].trim();
      if (city.isEmpty) continue;
      final result = _parseLine(line, cityOffset: 1);
      if (result == null) continue;
      _cityCache.putIfAbsent(city, () => {})[result.$1] = result.$2;
    }

    _availableCities = _cityCache.keys.toList()..sort();

    // Resolve active city — keep current if it exists, else use first available
    final target = _cityCache.containsKey(_activeCity)
        ? _activeCity
        : (_availableCities.isNotEmpty ? _availableCities.first : '');

    if (target.isNotEmpty) {
      _activeCity = target;
      _cache = _cityCache[_activeCity]!;
    }
  }

  /// Returns (dateKey, DailyPrayerTimes) or null.
  /// [cityOffset]: 0 = single-city (Date is col 0), 1 = multi-city (Date is col 1).
  (String, DailyPrayerTimes)? _parseLine(
    String line, {
    required int cityOffset,
  }) {
    if (line.isEmpty) return null;
    try {
      final parts = line.split(',');
      if (parts.length < 7 + cityOffset) return null;
      final dateStr = parts[0 + cityOffset].trim();
      final date = _parseDate(dateStr);
      if (date == null) return null;
      // Issue 12: map using dd/MM/yyyy exactly to match getToday constraints
      final normalizedKey =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      final entry = DailyPrayerTimes(
        date: date,
        fajr: _parseTime(date, parts[1 + cityOffset].trim()),
        sunrise: _parseTime(date, parts[2 + cityOffset].trim()),
        dhuhr: _parseTime(date, parts[3 + cityOffset].trim()),
        asr: _parseTime(date, parts[4 + cityOffset].trim()),
        maghrib: _parseTime(date, parts[5 + cityOffset].trim()),
        isha: _parseTime(date, parts[6 + cityOffset].trim()),
      );
      return (normalizedKey, entry);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDate(String s) {
    try {
      // Manual parsing is roughly 5x-10x faster than DateFormat('dd/MM/yyyy').parse
      final parts = s.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  DateTime _parseTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DailyPrayerTimes? getToday() {
    final now = DateTime.now();
    final key =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return _cache[key];
  }

  DailyPrayerTimes? getTomorrowByKey(String key) => _cache[key];

  Future<String> saveCustomFile(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/$_savedFileName');
    await File(sourcePath).copy(dest.path);
    await _loadFromFile(dest);
    return dest.path;
  }
}
