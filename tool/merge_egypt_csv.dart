// Merges egypt_esa_2026_m1_m12.csv into egypt_prayer_times_2026.csv.
//
// Usage:  dart run tool/merge_egypt_csv.dart
//
// Strategy:
//   - For every city that appears in the ESA file: replace ALL rows in the
//     main CSV with the ESA data (for all dates).
//   - For cities only in the main CSV (not covered by ESA): keep as-is.
//   - Result is sorted by city name, then date ascending.
//
// After this, run:  dart run tool/csv_to_sqlite.dart

import 'dart:io';
import 'package:path/path.dart' as p;

const _esaCsv  = 'assets/csv/egypt_esa_2026_m1_m12.csv';
const _mainCsv = 'assets/csv/egypt_prayer_times_2026.csv';

Future<void> main() async {
  final esaFile  = File(p.absolute(_esaCsv));
  final mainFile = File(p.absolute(_mainCsv));

  if (!esaFile.existsSync())  { stderr.writeln('Not found: $_esaCsv');  exit(1); }
  if (!mainFile.existsSync()) { stderr.writeln('Not found: $_mainCsv'); exit(1); }

  // Load ESA rows (skip header), group by city name.
  final esaLines = esaFile.readAsLinesSync().skip(1);
  final Map<String, List<String>> esaRows = {};
  for (final line in esaLines) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final city = t.split(',').first;
    esaRows.putIfAbsent(city, () => []).add(t);
  }
  final esaCities = esaRows.keys.toSet();
  final esaCount  = esaRows.values.fold(0, (s, l) => s + l.length);
  print('ESA file: $esaCount rows for ${esaCities.length} cities.');

  // Load main CSV, keep rows for cities NOT covered by ESA.
  final mainLines = mainFile.readAsLinesSync();
  final header    = mainLines.first;
  final kept      = <String>[];
  for (final line in mainLines.skip(1)) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final city = t.split(',').first;
    if (!esaCities.contains(city)) kept.add(t);
  }
  print('Kept ${kept.length} rows from original (cities not in ESA data).');

  // Merge and sort.
  final allRows = <String>[...kept];
  for (final rows in esaRows.values) allRows.addAll(rows);

  allRows.sort((a, b) {
    final ac = a.split(','), bc = b.split(',');
    final c  = ac[0].compareTo(bc[0]);
    return c != 0 ? c : _dateSortKey(ac[1]).compareTo(_dateSortKey(bc[1]));
  });

  final buf = StringBuffer()..writeln(header);
  for (final row in allRows) buf.writeln(row);
  mainFile.writeAsStringSync(buf.toString());

  print('Written: ${allRows.length} total rows → $_mainCsv');
  print('Next: dart run tool/csv_to_sqlite.dart');
}

/// "dd/MM/yyyy" → "yyyyMMdd" for lexicographic sort.
String _dateSortKey(String dmy) {
  final p = dmy.split('/');
  return p.length == 3 ? '${p[2]}${p[1]}${p[0]}' : dmy;
}
