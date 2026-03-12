// Fetches UAE prayer times for March–June 2026 from awqaf.gov.ae
// and merges them into assets/csv/uae_prayer_times_2026.csv.
//
// Usage:
//   dart run tool/fetch_awqaf_uae.dart --token="Bearer eyJ..."
//
// How to get the token:
//   1. Open https://www.awqaf.gov.ae/prayer-times in Chrome
//   2. DevTools → Network → filter "mobileappapi" → reload → click any request
//   3. Copy the "Authorization: Bearer ..." header value
//
// After this script finishes, rebuild the SQLite DB:
//   dart run tool/csv_to_sqlite.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _base = 'https://mobileappapi.awqaf.gov.ae/APIS/v3/prayer-time';
const _csvPath = 'assets/csv/uae_prayer_times_2026.csv';
const _targetMonths = [3, 4, 5, 6];
const _targetYear = 2026;

// DB city name → (emirateId, cityId) from mobileappapi.awqaf.gov.ae
// Discovered by inspecting /prayertimes/{year}/{month}/{emirateId}/{cityId}.
// Khor Fakkan + Kalba both map to Sharjah Eastern Coast (36); no separate IDs.
const _cityDefs = <String, (int, int)>{
  'Dubai':             (2, 32),
  'Abu Dhabi':         (1, 1),
  'Sharjah':           (3, 33),
  'Ajman':             (4, 41),
  'Umm Al Quwain':     (5, 44),
  'Ras Al Khaimah':    (6, 45),
  'Fujairah':          (7, 52),
  'Al Ain':            (1, 2),
  'Dibba Al-Fujairah': (7, 53),
  'Khor Fakkan':       (3, 36),
  'Kalba':             (3, 36),
  'Hatta':             (2, 60),
  'Al Dhaid':          (3, 34),
  'Ruwais':            (1, 27),
  'Madinat Zayed':     (1, 25),
};

Future<void> main(List<String> args) async {
  final token = _parseToken(args);
  if (token == null) {
    stderr.writeln('Error: --token="Bearer eyJ..." is required.');
    exit(1);
  }

  // Check for pre-fetched CSV file (avoids IP-restricted API calls).
  const _preFetchedCsv = 'assets/csv/uae_awqaf_mar_jun_2026.csv';
  final preFile = File(_preFetchedCsv);

  final Map<String, List<String>> newRows = {};

  if (preFile.existsSync()) {
    print('Using pre-fetched data from $_preFetchedCsv ...');
    final lines = preFile.readAsLinesSync().skip(1); // skip header
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final cols = trimmed.split(',');
      if (cols.length < 2) continue;
      final city = cols[0];
      newRows.putIfAbsent(city, () => []).add(trimmed);
    }
    final total = newRows.values.fold(0, (s, l) => s + l.length);
    print('Loaded $total rows for ${newRows.length} cities.');
  } else {
    // Live API fetch (requires token with Origin from awqaf.gov.ae domain).
    final headers = {
      'Authorization': token,
      'Accept': 'application/json',
      'Origin': 'https://www.awqaf.gov.ae',
      'Referer': 'https://www.awqaf.gov.ae/prayer-times',
    };

    for (final entry in _cityDefs.entries) {
      final dbName = entry.key;
      final (emirateId, cityId) = entry.value;
      final rows = <String>[];
      for (final month in _targetMonths) {
        print('  Fetching $dbName (emirate=$emirateId city=$cityId) month $month...');
        final url = '$_base/prayertimes/$_targetYear/$month/$emirateId/$cityId';
        final resp = await http.get(Uri.parse(url), headers: headers);
        if (resp.statusCode != 200) {
          stderr.writeln('    WARN: $dbName month $month → ${resp.statusCode}, skipping');
          continue;
        }
        final monthRows = _parseTimeRows(resp.body, dbName, month);
        rows.addAll(monthRows);
        print('    → ${monthRows.length} days');
      }
      newRows[dbName] = rows;
    }
  }

  print('\nMerging into $_csvPath...');
  _mergeCsv(newRows);

  print('Done. Now run: dart run tool/csv_to_sqlite.dart');
}

// ── Parsing ───────────────────────────────────────────────────────────────────

/// Parses the prayertimes response for one city/month.
/// Response shape: { "prayerData": [ { "gDate": "...", "fajr": "...", ... } ] }
/// Returns CSV lines: "CityName,dd/MM/yyyy,HH:MM,HH:MM,..."
List<String> _parseTimeRows(String body, String dbCityName, int month) {
  final decoded = json.decode(body);
  final list = (decoded is Map ? decoded['prayerData'] : decoded) as List? ?? [];
  final rows = <String>[];

  for (final item in list) {
    if (item is! Map) continue;

    // Date field — API uses "gDate" (Gregorian date ISO string)
    final dateRaw =
        (item['gDate'] ??
            item['PrayerDate'] ??
            item['prayerDate'] ??
            item['Date'] ??
            item['date'] ??
            '')
            .toString()
            .trim();
    if (dateRaw.isEmpty) continue;

    final dateFormatted = _normalizeDate(dateRaw, month);
    if (dateFormatted == null) continue;

    final fajr = _extractTime(item, ['Fajr', 'fajr', 'FajrTime', 'fajrTime']);
    final sunrise = _extractTime(
      item,
      ['Shurooq', 'shurooq', 'Sunrise', 'sunrise', 'SunriseTime'],
    );
    final dhuhr = _extractTime(
      item,
      ['zuhr', 'Zuhr', 'Dhuhr', 'dhuhr', 'DhuhrTime', 'dhuhrTime'],
    );
    final asr = _extractTime(item, ['Asr', 'asr', 'AsrTime', 'asrTime']);
    final maghrib = _extractTime(
      item,
      ['Maghrib', 'maghrib', 'MaghribTime', 'maghribTime'],
    );
    final isha = _extractTime(item, ['Isha', 'isha', 'IshaTime', 'ishaTime']);

    if ([fajr, sunrise, dhuhr, asr, maghrib, isha].any((t) => t == null)) {
      continue; // skip incomplete rows
    }

    rows.add('$dbCityName,$dateFormatted,$fajr,$sunrise,$dhuhr,$asr,$maghrib,$isha');
  }
  return rows;
}

// ── Time / date helpers ───────────────────────────────────────────────────────

/// Extracts and normalizes a time field to "HH:MM".
/// Handles "05:12", "05:12:00", "5:12 AM", ISO datetime strings.
String? _extractTime(Map item, List<String> keys) {
  for (final k in keys) {
    final raw = item[k]?.toString().trim();
    if (raw != null && raw.isNotEmpty) return _normalizeTime(raw);
  }
  return null;
}

/// Normalizes time strings to "HH:MM" (24-hour, zero-padded).
String? _normalizeTime(String raw) {
  // ISO datetime: "2026-03-11T05:12:00"
  final isoMatch = RegExp(r'T(\d{1,2}):(\d{2})').firstMatch(raw);
  if (isoMatch != null) {
    return '${isoMatch.group(1)!.padLeft(2, '0')}:${isoMatch.group(2)}';
  }

  // "HH:MM" or "HH:MM:SS" (24-hour)
  final hmsMatch = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw);
  if (hmsMatch != null) {
    final h = int.parse(hmsMatch.group(1)!);
    final m = hmsMatch.group(2)!;
    // Check for AM/PM suffix
    final isAm = raw.toUpperCase().contains('AM');
    final isPm = raw.toUpperCase().contains('PM');
    int hour = h;
    if (isPm && h != 12) hour = h + 12;
    if (isAm && h == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$m';
  }

  return null;
}

/// Normalizes various date formats to "dd/MM/yyyy".
/// Handles: "2026-03-11", "11/03/2026", "2026-03-11T..."
String? _normalizeDate(String raw, int expectedMonth) {
  // ISO date: "2026-03-11" or "2026-03-11T..."
  final isoMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
  if (isoMatch != null) {
    final y = isoMatch.group(1)!;
    final m = isoMatch.group(2)!;
    final d = isoMatch.group(3)!;
    return '$d/$m/$y';
  }

  // Already "dd/MM/yyyy"
  final dmyMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(raw);
  if (dmyMatch != null) return raw;

  return null;
}

// ── CSV merge ─────────────────────────────────────────────────────────────────

void _mergeCsv(Map<String, List<String>> newRows) {
  final file = File(_csvPath);
  if (!file.existsSync()) {
    stderr.writeln('CSV not found: $_csvPath');
    exit(1);
  }

  final existing = file.readAsLinesSync();
  final header = existing.first;

  // Build set of "CityName,dd/MM/yyyy" keys that are in our replacement range.
  final replacedKeys = <String>{};
  for (final lines in newRows.values) {
    for (final line in lines) {
      final cols = line.split(',');
      if (cols.length >= 2) replacedKeys.add('${cols[0]},${cols[1]}');
    }
  }

  // Keep existing rows that are NOT in the replacement range.
  final kept = <String>[];
  for (int i = 1; i < existing.length; i++) {
    final line = existing[i].trim();
    if (line.isEmpty) continue;
    final cols = line.split(',');
    if (cols.length >= 2) {
      final key = '${cols[0]},${cols[1]}';
      if (!replacedKeys.contains(key)) kept.add(line);
    }
  }

  // Combine kept + new rows, then sort by city name + date.
  final allRows = <String>[...kept];
  for (final lines in newRows.values) {
    allRows.addAll(lines);
  }

  allRows.sort((a, b) {
    final ac = a.split(',');
    final bc = b.split(',');
    final cityCompare = ac[0].compareTo(bc[0]);
    if (cityCompare != 0) return cityCompare;
    // Sort dates: parse dd/MM/yyyy → yyyyMMdd for comparison
    return _dateToSortKey(ac[1]).compareTo(_dateToSortKey(bc[1]));
  });

  final output = StringBuffer();
  output.writeln(header);
  for (final row in allRows) {
    output.writeln(row);
  }
  file.writeAsStringSync(output.toString());

  final newCount = newRows.values.fold(0, (s, l) => s + l.length);
  print(
    'Merged: kept ${kept.length} existing rows, replaced/added $newCount new rows. '
    'Total: ${allRows.length} rows.',
  );
}

/// Converts "dd/MM/yyyy" → "yyyyMMdd" for lexicographic date sorting.
String _dateToSortKey(String dmy) {
  final p = dmy.split('/');
  if (p.length != 3) return dmy;
  return '${p[2]}${p[1]}${p[0]}';
}

// ── CLI argument parsing ──────────────────────────────────────────────────────

String? _parseToken(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--token=')) return arg.substring('--token='.length);
  }
  return null;
}
