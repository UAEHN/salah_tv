// Correct legacy tables that postponed winter time until 26 October 2026.
// Palestine's official transition is 24 October; the remaining legacy cities
// follow the Asia/Jerusalem transition on 25 October. Newer tables are correct.
// Source: https://www.wafa.ps/news/2026/10/24/
// Usage: dart run tool/apply_palestine_winter_2026.dart
// Then regenerate downloadable files with: dart run tool/csv_to_json.dart

import 'dart:io';

const palestineWinterLegacyCities = <String, int>{
  'Jerusalem': 24,
  'East Jerusalem': 24,
  'Gaza': 24,
  'Nablus': 24,
  'Hebron': 24,
  'Ramallah': 24,
  'Jenin': 24,
  'Tulkarem': 24,
  'Qalqilya': 24,
  'Jericho': 24,
  'Khan Yunis': 24,
  'Az-Zahiriyya': 24,
  'Idna': 24,
  'Haifa': 25,
  'Beersheba': 25,
  'Nazareth': 25,
  'Acre': 25,
  'Lod': 25,
  'Ramla': 25,
  'Umm al-Fahm': 25,
  'Tiberias': 25,
  'At-Taiba': 25,
  'Zefat': 25,
  'Sakhnin': 25,
  'Tamra': 25,
  'Kafr Qasem': 25,
  'Qalansawe': 25,
  'Kafr Manda': 25,
  'Jisr az-Zarqa': 25,
  'Iksal': 25,
  'Al-Fureidis': 25,
  'Deburiyya': 25,
  'Bir al-Maksur': 25,
  'Kafr Yasif': 25,
  'Et Tera': 25,
};

void main() {
  final file = File('assets/csv/palestine_prayer_times_2026.csv');
  final result = correctPalestineWinter2026(file.readAsLinesSync());
  if (result.changedRows > 0) {
    file.writeAsStringSync('${result.lines.join('\n')}\n');
  }
  stdout.writeln('Updated ${result.changedRows} Palestine winter-time rows.');
}

/// Checks against each city's already-correct 26 October solar noon so running
/// this again cannot subtract another hour. Validate everything before writing.
({List<String> lines, int changedRows}) correctPalestineWinter2026(
  List<String> lines,
) {
  final winterNoon = <String, int>{};
  for (final line in lines.skip(1)) {
    final columns = line.split(',');
    if (columns.length == 8 && columns[1] == '26/10/2026') {
      winterNoon[columns[0]] = _minutes(columns[4]);
    }
  }

  var changedRows = 0;
  final corrected = <String>[];
  for (final line in lines) {
    final columns = line.split(',');
    final startDay = palestineWinterLegacyCities[columns.first];
    if (columns.length == 8 && startDay != null) {
      for (var day = startDay; day < 26; day++) {
        if (columns[1] != '$day/10/2026') continue;
        final reference = winterNoon[columns[0]];
        if (reference == null) {
          throw StateError('Missing winter reference for ${columns[0]}');
        }
        final delta = _minutes(columns[4]) - reference;
        if (delta.abs() <= 2) break; // Already corrected.
        if ((delta - 60).abs() > 2) {
          throw StateError('Unexpected solar noon: $line');
        }
        for (var index = 2; index < 8; index++) {
          final minutes = _minutes(columns[index]) - 60;
          if (minutes < 0) throw StateError('Invalid prayer time: $line');
          columns[index] =
              '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
              '${(minutes % 60).toString().padLeft(2, '0')}';
        }
        changedRows++;
      }
    }
    corrected.add(columns.join(','));
  }
  return (lines: corrected, changedRows: changedRows);
}

int _minutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
