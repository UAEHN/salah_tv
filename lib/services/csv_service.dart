import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_prayer_times.dart';

class CsvService {
  static final CsvService _instance = CsvService._internal();
  factory CsvService() => _instance;
  CsvService._internal();

  final Map<String, DailyPrayerTimes> _cache = {};
  static const _assetPath = 'assets/csv/prayer_times.csv';
  static const _savedFileName = 'prayer_times_custom.csv';

  bool get hasData => _cache.isNotEmpty;

  Future<void> initialize(String? customPath) async {
    try {
      if (customPath != null && File(customPath).existsSync()) {
        await _loadFromFile(File(customPath));
      } else {
        await _loadFromAsset();
      }
    } catch (e) {
      await _loadFromAsset();
    }
  }

  Future<void> _loadFromAsset() async {
    final content = await rootBundle.loadString(_assetPath);
    _parseContent(content);
  }

  Future<void> _loadFromFile(File file) async {
    final content = await file.readAsString();
    _parseContent(content);
  }

  void _parseContent(String content) {
    _cache.clear();
    final lines = content.split('\n');
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      try {
        final parts = line.split(',');
        if (parts.length < 7) continue;
        final dateStr = parts[0].trim();
        final date = _parseDate(dateStr);
        if (date == null) continue;

        final entry = DailyPrayerTimes(
          date: date,
          fajr: _parseTime(date, parts[1].trim()),
          sunrise: _parseTime(date, parts[2].trim()),
          dhuhr: _parseTime(date, parts[3].trim()),
          asr: _parseTime(date, parts[4].trim()),
          maghrib: _parseTime(date, parts[5].trim()),
          isha: _parseTime(date, parts[6].trim()),
        );
        _cache[dateStr] = entry;
      } catch (_) {
        continue;
      }
    }
  }

  DateTime? _parseDate(String s) {
    try {
      return DateFormat('dd/MM/yyyy').parse(s);
    } catch (_) {
      return null;
    }
  }

  DateTime _parseTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DailyPrayerTimes? getToday() {
    final key = DateFormat('dd/MM/yyyy').format(DateTime.now());
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

  int get totalDays => _cache.length;
}
