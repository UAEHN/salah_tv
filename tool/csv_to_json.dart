// Build-time script — converts CSV prayer-time files to per-city JSON files
// and a manifest.json used by the app for background update detection.
//
// Usage:  dart run tool/csv_to_json.dart
//
// Input:  assets/csv/*.csv
// Output:
//   out/prayer_data/{country}/{city_slug}.json   — one file per city
//   out/prayer_data/manifest.json               — {slug: hash} for update checks
//
// JSON format (columnar integers — same encoding as the SQLite DB):
//   { "v": 2, "hash": "a3f9c1ab", "country": "uae", "city": "Dubai",
//     "year": 2026,
//     "cols": ["date","fajr","sunrise","dhuhr","asr","maghrib","isha"],
//     "rows": [[20260101, 312, 425, 748, 926, 1067, 1147], ...] }
//
// City slug: name.toLowerCase().replaceAll(' ', '_').replaceAll("'", '')
// Hash: djb2 checksum of all integer values — changes when data changes.

import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final csvDir = Directory('assets/csv');
  if (!csvDir.existsSync()) {
    stderr.writeln('ERROR: assets/csv/ not found. Run from project root.');
    exit(1);
  }

  final outDir = Directory('out/prayer_data');
  outDir.createSync(recursive: true);

  final manifest = <String, String>{};
  var fileCount = 0;

  for (final entity in csvDir.listSync()..sort((a, b) => a.path.compareTo(b.path))) {
    if (entity is! File || !entity.path.endsWith('.csv')) continue;

    final fname      = entity.uri.pathSegments.last;
    final countryKey = _deriveCountryKey(fname);
    if (countryKey == 'default') continue; // skip fallback CSV

    final lines   = entity.readAsLinesSync();
    if (lines.isEmpty) continue;
    final isMulti = lines.first.trim().toLowerCase().startsWith('city,');
    final year    = _extractYear(fname);

    // Group rows by city.
    final cityRows = <String, List<List<int>>>{};
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = line.split(',');
      final minCols = isMulti ? 8 : 7;
      if (cols.length < minCols) continue;

      final offset   = isMulti ? 1 : 0;
      final cityName = isMulti ? cols[0].trim() : 'Dubai';

      (cityRows[cityName] ??= []).add([
        _dateToInt(cols[0 + offset].trim()),
        _timeToInt(cols[1 + offset].trim()),
        _timeToInt(cols[2 + offset].trim()),
        _timeToInt(cols[3 + offset].trim()),
        _timeToInt(cols[4 + offset].trim()),
        _timeToInt(cols[5 + offset].trim()),
        _timeToInt(cols[6 + offset].trim()),
      ]);
    }

    // Write one JSON file per city.
    final countryDir = Directory('out/prayer_data/$countryKey');
    countryDir.createSync(recursive: true);

    cityRows.forEach((cityName, rows) {
      final hash = _computeHash(rows);
      final slug = _toCitySlug(cityName);

      final json = {
        'v':       2,
        'hash':    hash,
        'country': countryKey,
        'city':    cityName,
        'year':    year,
        'cols':    ['date', 'fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'],
        'rows':    rows,
      };

      File('out/prayer_data/$countryKey/$slug.json')
          .writeAsStringSync(jsonEncode(json));

      manifest['$countryKey/$slug'] = hash;
      fileCount++;
    });

    print('  OK  $fname → ${cityRows.length} cities');
  }

  // Write manifest.json.
  final manifestJson = jsonEncode({
    'generated': DateTime.now().toIso8601String().substring(0, 10),
    'cities':    manifest,
  });
  File('out/prayer_data/manifest.json').writeAsStringSync(manifestJson);

  print('\nDone: $fileCount city files + manifest.json written to out/prayer_data/');
  print('Upload the contents of out/prayer_data/ to:');
  print('  https://uaehn.github.io/salah_tv/prayer_data/');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _deriveCountryKey(String fileName) {
  if (fileName == 'prayer_times.csv') return 'default';
  return fileName.replaceAll(RegExp(r'_prayer_times_\d+\.csv$'), '');
}

int _extractYear(String fileName) {
  final match = RegExp(r'(\d{4})').firstMatch(fileName);
  return match != null ? int.parse(match.group(1)!) : DateTime.now().year;
}

/// "dd/MM/yyyy" or "yyyy-MM-dd" → YYYYMMDD integer.
int _dateToInt(String s) {
  if (s.contains('-')) {
    final p = s.split('-');
    return int.parse(p[0]) * 10000 + int.parse(p[1]) * 100 + int.parse(p[2]);
  }
  final p = s.split('/');
  return int.parse(p[2]) * 10000 + int.parse(p[1]) * 100 + int.parse(p[0]);
}

/// "HH:MM" → minutes since midnight.
int _timeToInt(String s) {
  final p = s.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// djb2-style hash of all integer values — pure Dart, no external packages.
String _computeHash(List<List<int>> rows) {
  var h = 5381;
  for (final row in rows) {
    for (final v in row) {
      h = ((h << 5) + h) ^ v;
    }
  }
  return (h & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
}

/// Converts a city name to a URL-safe slug.
/// "Abu Dhabi" → "abu_dhabi" / "Ras Al Khaimah" → "ras_al_khaimah"
String _toCitySlug(String name) =>
    name.toLowerCase().replaceAll("'", '').replaceAll(' ', '_');
