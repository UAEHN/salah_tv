// One-off generator: adds the cities listed in the official 2025/2026
// Algerian Ministry calendars (Alger / Djelfa / Adrar booklets + their
// associated towns) to the app.
//
//   1. assets/world_cities.json  — so the city is *searchable* in the picker
//   2. assets/csv/algeria_prayer_times_2026.csv — so it gets official-grade
//      JSON published to gh-pages (only when no data slug exists yet)
//
// Prayer math: adhan_dart Muslim World League (Algeria's default, 18°/17°),
// Algeria = UTC+1 year-round (no DST), Maghrib = sunset + 3 min (matches the
// existing Algeria dataset and the Ministry PDFs to within ~1 minute —
// validated against Algiers/Oran/Djelfa/Adrar).
//
// Usage:  dart run tool/gen_algeria_cities.dart
// Idempotent: skips picker entries whose Arabic name already exists and
// skips data generation for slugs that already have a JSON file.
import 'dart:convert';
import 'dart:io';
import 'package:adhan_dart/adhan_dart.dart';

/// [ar, en, lat, lng, alt]
const List<List<Object>> kCities = [
  // ── already have prayer_data (picker entry only, reuses existing JSON) ──
  ['عين الدفلى', 'Ain Defla', 36.2639, 1.9678, 230],
  ['البويرة', 'Bouira', 36.3736, 3.9019, 525],
  ['المسيلة', 'Msila', 35.7058, 4.5419, 441],
  ['برج بوعريريج', 'Bordj Bou Arreridj', 36.0731, 4.7608, 928],
  ['ميلة', 'Milah', 36.4503, 6.2644, 464],
  ['أم البواقي', 'Um al-Bouaki', 35.8775, 7.1136, 889],
  ['قالمة', 'Qalma', 36.4625, 7.4264, 290],
  ['سوق أهراس', 'Souk Ahras', 36.2864, 7.9511, 630],
  ['أولاد جلال', 'Oulad Djallal', 34.4178, 5.0664, 188],
  ['معسكر', 'Mascara', 35.3942, 0.1411, 590],
  ['سعيدة', 'Saida', 34.8303, 0.1517, 750],
  ['البيض', 'El Bayadh', 33.6831, 1.0192, 1341],
  ['عين وسارة', 'Ain Wasara', 35.4514, 2.9056, 740],
  ['الأغواط', 'Al-Aghwat', 33.8000, 2.8650, 750],
  ['عين الملح', 'Ain el Melh', 34.8419, 4.1681, 730],
  ['بوسعادة', 'Bousaada', 35.2125, 4.1772, 560],
  ['تقرت', 'Tuggurt', 33.1056, 6.0578, 85],
  ['خنشلة', 'Khenchela', 35.4361, 7.1436, 1200],
  ['بئر العاتر', 'Bir al-Ater', 34.7406, 8.0606, 900],
  ['إليزي', 'Illizi', 26.4833, 8.4667, 558],
  ['تيميمون', 'Timimoun', 29.2639, 0.2306, 312],
  // ── no data yet (picker entry + CSV generation) ──
  ['عين تموشنت', 'Ain Temouchent', 35.2974, -1.1387, 80],
  ['غليزان', 'Relizane', 35.7373, 0.5556, 85],
  ['تيبازة', 'Tipaza', 36.5894, 2.4486, 10],
  ['بومرداس', 'Boumerdes', 36.7667, 3.4772, 18],
  ['دلس', 'Dellys', 36.9136, 3.9133, 20],
  ['تيزي وزو', 'Tizi Ouzou', 36.7169, 4.0497, 200],
  ['الطارف', 'El Tarf', 36.7672, 8.3139, 27],
  ['مستغانم', 'Mostaganem', 35.9311, 0.0892, 104],
  ['المغير', 'El Mghair', 33.9539, 5.9244, 70],
  ['مغنية', 'Maghnia', 34.8419, -1.7811, 426],
  ['النعامة', 'Naama', 33.2667, -0.3128, 1167],
  ['تيسمسيلت', 'Tissemsilt', 35.6072, 1.8106, 860],
  ['حاسي الرمل', 'Hassi Rmel', 32.9239, 3.2647, 750],
  ['الوادي', 'El Oued', 33.3683, 6.8631, 62],
  ['تيارت', 'Tiaret', 35.3700, 1.3200, 1000],
  ['عين أمناس', 'In Amenas', 28.0500, 9.5500, 562],
  ['جانت', 'Djanet', 24.5536, 9.4842, 1050],
  ['إن قزام', 'In Guezzam', 19.5686, 5.7728, 399],
  ['المنيعة', 'El Menia', 30.5833, 2.8833, 397],
  ['إن صالح', 'In Salah', 27.1939, 2.4733, 280],
  ['برج باجي مختار', 'Bordj Badji Mokhtar', 21.3281, 0.9544, 415],
  ['بني عباس', 'Beni Abbes', 30.1308, -2.1672, 500],
  ['تندوف', 'Tindouf', 27.6711, -8.1478, 443],
  ['رقان', 'Reggane', 26.7156, 0.1722, 295],
  ['بني ونيف', 'Beni Ounif', 32.0469, -1.2519, 800],
];

String _slug(String name) =>
    name.toLowerCase().replaceAll("'", '').replaceAll(' ', '_');

String _two(int v) => v.toString().padLeft(2, '0');

/// adhan_dart returns UTC; Algeria = UTC+1, no DST. [addMin] for Maghrib +3.
String _fmt(DateTime utc, {int addMin = 0}) {
  final t = utc.add(Duration(hours: 1, minutes: addMin));
  return '${_two(t.hour)}:${_two(t.minute)}';
}

void main() {
  final wcFile = File('assets/world_cities.json');
  final wc = jsonDecode(wcFile.readAsStringSync()) as Map<String, dynamic>;
  final cities = (wc['cities'] as List).cast<Map<String, dynamic>>();
  final existingArabic = {
    for (final c in cities)
      if (c['c'] == 'DZ') c['a'] as String,
  };

  final algeriaDir = Directory('out/prayer_data/algeria');
  final existingSlugs = <String>{
    for (final f in algeriaDir.listSync())
      if (f.path.endsWith('.json'))
        f.uri.pathSegments.last.replaceAll('.json', ''),
  };

  final csvLines = <String>[];
  var addedPicker = 0;
  final generated = <String>[];

  for (final row in kCities) {
    final ar = row[0] as String;
    final en = row[1] as String;
    final lat = row[2] as double;
    final lng = row[3] as double;
    final alt = row[4] as int;
    final slug = _slug(en);

    if (!existingArabic.contains(ar)) {
      cities.add({
        'n': en,
        'a': ar,
        'c': 'DZ',
        'lat': lat,
        'lng': lng,
        'm': 'algeria',
        'alt': alt,
        'tz': 1.0,
      });
      addedPicker++;
    }

    if (!existingSlugs.contains(slug)) {
      final coords = Coordinates(lat, lng);
      for (var d = DateTime.utc(2026, 1, 1);
          d.year == 2026;
          d = d.add(const Duration(days: 1))) {
        final p = PrayerTimes(
          date: d,
          coordinates: coords,
          calculationParameters:
              CalculationMethodParameters.muslimWorldLeague(),
        );
        final date = '${_two(d.day)}/${_two(d.month)}/${d.year}';
        csvLines.add('$en,$date,${_fmt(p.fajr)},${_fmt(p.sunrise)},'
            '${_fmt(p.dhuhr)},${_fmt(p.asr)},${_fmt(p.maghrib, addMin: 3)},'
            '${_fmt(p.isha)}');
      }
      generated.add('$en ($slug)');
    }
  }

  wcFile.writeAsStringSync(jsonEncode(wc));

  if (csvLines.isNotEmpty) {
    final csv = File('assets/csv/algeria_prayer_times_2026.csv');
    final existing = csv.readAsStringSync().trimRight();
    csv.writeAsStringSync('$existing\n${csvLines.join('\n')}\n');
  }

  stdout.writeln('picker entries added : $addedPicker');
  stdout.writeln('data cities generated: ${generated.length}');
  for (final g in generated) {
    stdout.writeln('  + $g');
  }
}
