import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/apply_palestine_winter_2026.dart';

void main() {
  const header = 'City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha';
  const summer = '05:28,06:47,12:23,15:32,18:03,19:18';
  const winter = '04:28,05:47,11:23,14:32,17:03,18:18';

  test('corrects all six times only in each city transition window', () {
    final lines = [
      header,
      'Gaza,23/10/2026,$summer',
      'Gaza,24/10/2026,$summer',
      'Gaza,25/10/2026,$summer',
      'Gaza,26/10/2026,$winter',
      'Haifa,24/10/2026,$summer',
      'Haifa,25/10/2026,$summer',
      'Haifa,26/10/2026,$winter',
      'Salfit,24/10/2026,$winter',
    ];

    final result = correctPalestineWinter2026(lines);

    expect(result.changedRows, 3);
    expect(result.lines, [
      header,
      'Gaza,23/10/2026,$summer',
      'Gaza,24/10/2026,$winter',
      'Gaza,25/10/2026,$winter',
      'Gaza,26/10/2026,$winter',
      'Haifa,24/10/2026,$summer',
      'Haifa,25/10/2026,$winter',
      'Haifa,26/10/2026,$winter',
      'Salfit,24/10/2026,$winter',
    ]);
    final repeated = correctPalestineWinter2026(result.lines);
    expect(repeated.changedRows, 0);
    expect(repeated.lines, result.lines);
  });

  test('rejects unexpected data before the source file can be written', () {
    expect(
      () => correctPalestineWinter2026([
        header,
        'Gaza,24/10/2026,05:28,06:47,13:23,15:32,18:03,19:18',
        'Gaza,26/10/2026,$winter',
      ]),
      throwsStateError,
    );
  });

  test('CSV and downloadable city files contain the same corrected times', () {
    final lines = File(
      'assets/csv/palestine_prayer_times_2026.csv',
    ).readAsLinesSync();
    expect(correctPalestineWinter2026(lines).changedRows, 0);
    final manifest =
        jsonDecode(File('out/prayer_data/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final cities = manifest['cities'] as Map<String, dynamic>;

    for (final entry in palestineWinterLegacyCities.entries) {
      final slug = entry.key
          .toLowerCase()
          .replaceAll("'", '')
          .replaceAll(' ', '_');
      final json =
          jsonDecode(
                File('out/prayer_data/palestine/$slug.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(cities['palestine/$slug'], json['hash']);
      final rows = json['rows'] as List<dynamic>;
      for (var day = 23; day <= 27; day++) {
        final csv = lines
            .firstWhere((line) => line.startsWith('${entry.key},$day/10/2026,'))
            .split(',');
        final row =
            (rows.singleWhere(
                      (dynamic row) =>
                          (row as List<dynamic>).first == 20261000 + day,
                    )
                    as List<dynamic>)
                .cast<int>();
        final minutes = csv.skip(2).map((time) {
          final parts = time.split(':');
          return int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }).toList();
        expect(row.skip(1), minutes, reason: '${entry.key} day $day');
        expect(
          row[3],
          day < entry.value
              ? inInclusiveRange(720, 755)
              : inInclusiveRange(660, 695),
          reason: '${entry.key} day $day must follow its local clock',
        );
      }
    }
  });
}
