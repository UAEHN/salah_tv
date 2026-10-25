// Temporary, calculated city tables for clients without Atlantic/Canary fixes.
// Run: dart run tool/build_canary_temporary_tables.dart
// Then: dart run tool/csv_to_json.dart
// Coordinates: GeoNames ES.zip, retrieved 2026-10-25, CC BY 4.0.
// https://download.geonames.org/export/dump/ES.zip
// Same MWL/Shafi calculation and minute display as the app; not mosque tables.

import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const canaryTableCities = [
  (name: 'Pajara - Fuerteventura', lat: 28.35039, lng: -14.1076, id: 2513026),
];

void main() {
  tz_data.initializeTimeZones();
  final location = tz.getLocation('Atlantic/Canary');
  final output = StringBuffer(
    'City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha\n',
  );
  var count = 0;
  for (final city in canaryTableCities) {
    for (
      var date = DateTime.utc(2026);
      date.year == 2026;
      date = date.add(const Duration(days: 1))
    ) {
      final prayers = PrayerTimes(
        date: date,
        coordinates: Coordinates(city.lat, city.lng),
        calculationParameters: CalculationMethodParameters.muslimWorldLeague(),
      );
      final times = [
        prayers.fajr,
        prayers.sunrise,
        prayers.dhuhr,
        prayers.asr,
        prayers.maghrib,
        prayers.isha,
      ];
      final minutes = times.map((utc) {
        final local = tz.TZDateTime.from(utc, location);
        if (local.year != date.year ||
            local.month != date.month ||
            local.day != date.day) {
          throw StateError(
            'Prayer outside its calendar date: ${city.name} $date',
          );
        }
        return local.hour * 60 + local.minute;
      }).toList();
      for (var i = 1; i < minutes.length; i++) {
        if (minutes[i] <= minutes[i - 1]) {
          throw StateError('Invalid prayer order: ${city.name} $date');
        }
      }
      final dateKey = '${_pad(date.day)}/${_pad(date.month)}/${date.year}';
      output.writeln(
        '${city.name},$dateKey,${minutes.map((m) => '${_pad(m ~/ 60)}:${_pad(m % 60)}').join(',')}',
      );
      count++;
    }
  }
  File(
    'assets/csv/canary_islands_prayer_times_2026.csv',
  ).writeAsStringSync(output.toString());
  stdout.writeln('Generated $count calculated Canary city-days for 2026.');
}

String _pad(int value) => value.toString().padLeft(2, '0');
