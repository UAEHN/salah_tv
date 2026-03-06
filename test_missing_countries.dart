import 'dart:io';
import 'package:intl/intl.dart';
import 'lib/core/city_translations.dart';

DateTime? _parseDate(String s) {
  try {
    return DateFormat('dd/MM/yyyy').parse(s);
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

bool isValidLine(String line) {
  if (line.isEmpty) return false;
  try {
    final parts = line.split(',');
    if (parts.length < 8) return false;
    final dateStr = parts[1].trim();
    final date = _parseDate(dateStr);
    if (date == null) return false;
    _parseTime(date, parts[2].trim());
    _parseTime(date, parts[3].trim());
    _parseTime(date, parts[4].trim());
    _parseTime(date, parts[5].trim());
    _parseTime(date, parts[6].trim());
    _parseTime(date, parts[7].trim());
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  final dir = Directory('assets/csv');
  final csvFiles = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.csv') && f.path.contains('2026'),
  );
  final allCsvCities = <String>{};

  for (var file in csvFiles) {
    final lines = file.readAsLinesSync();
    if (lines.isEmpty) continue;
    if (lines[0].toLowerCase().startsWith('city,')) {
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i];
        final parts = line.split(',');
        if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
          if (isValidLine(line)) {
            allCsvCities.add(parts[0].trim());
          }
        }
      }
    }
  }

  print('Total fully valid unique CSV cities found: ${allCsvCities.length}');

  final availableCountries = <String>[];
  final missingCountries = <String>[];

  for (final c in kCountries) {
    final matching = allCsvCities
        .where((city) => c.cities.contains(city))
        .toList();
    if (matching.isNotEmpty) {
      availableCountries.add(c.key);
      print('✅ Country OK: ${c.key} (matched ${matching.length} cities)');
    } else {
      missingCountries.add(c.key);
      print('❌ Country MISSING: ${c.key}');

      // Look at failing lines for this country's suspected file
      final file = csvFiles.firstWhere(
        (f) => f.path.contains(c.key.toLowerCase()),
        orElse: () => File(''),
      );
      if (file.path.isNotEmpty) {
        final lines = file.readAsLinesSync();
        print('   -> First failing data line in ${file.path}:');
        for (var i = 1; i < lines.length; i++) {
          if (!isValidLine(lines[i])) {
            print('      ${lines[i]}');
            break;
          }
        }
      }
    }
  }
}
