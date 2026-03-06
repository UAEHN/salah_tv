// Algeria Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/3
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_algeria.dart
//
// Output:
//   assets/csv/algeria_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/algeria_prayer_times_2026.csv';
const int kCountryId = 3;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Algeria Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/3
// ---------------------------------------------------------------------------

const List<List<String>> kAlgeriaCities = [
  // Major cities
  ['Algiers',              'الجزائر',          '18848'],
  ['Oran',                 'وهران',            '186'],
  ['Constantine',          'قسنطينة',          '187'],
  ['Annaba',               'عنابة',            '190'],
  ['Blida',                'البليدة',          '15951'],
  ['Batna',                'باتنة',            '18315'],
  ['Setif',                'سطيف',             '10865'],
  ['Sidi Bel Abbes',       'سيدي بلعباس',      '191'],
  ['Biskra',               'بسكرة',            '15037'],
  ['Tlemcen',              'تلمسان',           '198'],
  ['Bechar',               'بشار',             '197'],
  ['Bjaiya',               'بجاية',            '193'],
  ['Skikda',               'سكيكدة',           '194'],
  ['Saida',                'صيدا',             '201'],
  ['Mascara',              'مستغانم',          '199'],
  ['Qalma',                'قالمة',            '202'],
  ['Medea',                'المدية',           '196'],
  ['Djelfa',               'الجلفة',           '13836'],
  ['Ouargla',              'ورقلة',            '11324'],
  ['Ghardaia',             'غرداية',           '11376'],
  ['Bouira',               'البويرة',          '11332'],
  ['Jijel',                'جيجل',             '18338'],
  ['Tebessa',              'تبسة',             '18932'],
  ['Khenchela',            'خنشلة',            '12734'],
  ['Souk Ahras',           'سوق أهراس',        '16077'],
  ['M\'Sila',              'المسيلة',          '18881'],
  ['El Bayadh',            'البيض',            '19622'],
  ['Bordj Bou Arreridj',   'برج بوعريريج',     '13320'],
  ['Chlef',                'الشلف',            '15940'],
  ['Ain Defla',            'عين الدفلة',       '10863'],
  ['Tamanrasset',          'تمنراست',          '219'],
  ['Adrar',                'أدرار',            '16114'],
  ['Illizi',               'إليزي',            '19798'],
  ['Hassi Messaoud',       'حاسي مسعود',       '16176'],
  ['Ouargla Alt',          'الوادي',           '13625'],
  ['Bousaada',             'بوسعادة',          '16056'],

  // Northern cities
  ['Bab az-Zuwwar',        'باب الزوار',       '189'],
  ['Bir al-Jir',           'بئر الجير',        '232'],
  ['Burj al-Kiffan',       'برج الكيفان',      '203'],
  ['Braqi',                'براقي',            '207'],
  ['Bir Khadem',           'بيرخادم',          '222'],
  ['Dar Sheikh',           'دار شيخ',          '252'],
  ['Rouiba',               'الرويبة',          '19126'],
  ['Dar el Beida',         'الدار البيضاء',    '18791'],
  ['Cheraga',              'Cheraga',          '19797'],
  ['El Achour',            'El Achour',        '16174'],
  ['Ben Aknoune',          'Ben \'Aknoûn',     '18418'],
  ['Baba Hassen',          'Baba Hassen',      '19156'],
  ['Kolea',                'Kolea',            '18733'],
  ['Bouinan',              'Bouinan',          '18882'],
  ['Oued el Alleug',       'Oued el Alleug',   '18792'],
  ['Ouled Fayet',          'Ouled Fayet',      '16358'],
  ['Saoula',               'Saoula',           '16162'],
  ['Tixeraine',            'Tixeraïne',        '16060'],
  ['Le Lido',              'Le Lido',          '16155'],
  ['El Hamiz',             'El Hamiz',         '15957'],
  ['L\'Agha',              'L\'Agha',          '18593'],
  ['Mustapha Superieur',   'Mustapha Supérieur','15650'],
  ['El Hadjira',           'El Hadjira',       '15983'],

  // Northeast
  ['Ash-Shatiya',          'الشطية',           '192'],
  ['Ain al-Bayda',         'عين البيضاء',      '206'],
  ['Um al-Bouaki',         'أم البواقي',       '208'],
  ['Ain Fakrun',           'عين فكرون',        '229'],
  ['Shalgum al-Aid',       'شلغوم العيد',      '223'],
  ['Milah',                'ميلة',             '226'],
  ['Bisbis',               'بيسبيس',           '234'],
  ['Berrahal',             'Berrahal',         '17862'],
  ['Ahmed Rachedi',        'Ahmed Rachedi',    '19968'],
  ['El Aouinet',           'El Aouinet',       '15658'],
  ['El Kala',              'القل',             '18680'],
  ['Ain el Bya',           'Aïn el Bya',       '11223'],
  ['Melouza',              'Melouza',          '11520'],
  ['Salah Bey',            'صالح باي',         '13173'],
  ['Rouached',             'Rouached',         '18808'],
  ['Chorfa',               'Chorfa',           '18796'],

  // Center-west
  ['Al-Kharub',            'الخروب',           '213'],
  ['Al-Alma',              'العلمة',           '200'],
  ['Al-Mansura',           'المنصورة',         '255'],
  ['Brika',                'بريكة',            '210'],
  ['Msaad',                'مسعد',             '209'],
  ['Miftah',               'مفتاح',            '241'],
  ['Boufrik',              'بوفاريك',          '243'],
  ['Bani Murad',           'بني مراد',         '211'],
  ['Budwaw',               'بودواو',           '269'],
  ['Rijayba',              'ريجويبة',          '240'],
  ['Sur al-Ghuzlan',       'صور الغزلان',      '259'],
  ['Boghni',               'بوغني',            '251'],
  ['Dra al-Mizan',         'درعة الميزان',     '278'],
  ['Timiziart',            'تيميزارت',         '279'],
  ['Tasbast',              'تبسبست',           '281'],
  ['Ain el Melh',          'Aïn el Melh',      '13203'],
  ['Sidi al-Safai',        'سيدي الصافي',      '12878'],
  ['Ouled Bel Hadj',       'Ouled Bel Hadj',   '16160'],
  ['Ain Deheb',            'Aïn Deheb',        '15955'],
  ['Bou Hamdoune',         'Bou Hamdoune',     '15985'],
  ['Bou Zorane',           'Bou Zorane',       '14249'],
  ['Oumzizou',             'Oumzizou',         '16028'],
  ['Lardjem',              'Lardjem',          '19828'],
  ['Ain el Hajel',         'عين الهجل',        '275'],
  ['Oued Sidi Slimane',    'Oued Sidi Slimane','18784'],

  // West
  ['Al-Aghwat',            'الأغواط',          '205'],
  ['Aflou',                'افلو',             '212'],
  ['Khimis Miliana',       'خميس مليانة',      '217'],
  ['Ain Wasara',           'عين وسرة',         '204'],
  ['Ain Safra',            'عين صفراء',        '236'],
  ['Frenda',               'فرندا',            '237'],
  ['Qasr al-Bukhari',      'قصر البخاري',      '216'],
  ['Al-Ashir',             'العشير',           '195'],
  ['Buqura',               'بوقرة',            '238'],
  ['Sig',                  'سيج',              '244'],
  ['Sidi Musa',            'سيدي موسى',        '246'],
  ['Sidi Issa',            'سيدي عيسى',        '224'],
  ['Larba',                'لاربا',            '225'],
  ['Shirya',               'شيريا',            '221'],
  ['Khimis al-Khashna',    'خميس الخشنة',      '261'],
  ['Ar-Ruwaysat',          'الرويسات',         '214'],
  ['Barwajiya',            'برواجية',          '215'],
  ['Al-Ataf',              'العطاف',           '273'],
  ['Al-Afrun',             'العفرون',          '274'],
  ['Wad Rahu',             'واد رهو',          '242'],
  ['Wadi Fuda',            'وادي فودة',        '271'],
  ['Hanaya',               'حنايا',            '276'],
  ['Mecheria',             'Mecheria',         '17208'],
  ['El Abiodh Sidi Cheikh','El Abiodh Sidi Cheikh','18408'],
  ['Nedroma',              'Nedroma',          '19036'],
  ['Sahnoun',              'Sahnoun',          '12848'],
  ['Bu Arfa',              'بوعرفة',           '272'],
  ['Bani Saf',             'بني صاف',          '268'],
  ['Sabra',                'Sabra',            '15110'],

  // South & Sahara
  ['Tuggurt',              'تقرت',             '264'],
  ['Timimoun',             'تيميمون',          '262'],
  ['Tulga',                'تولجا',            '230'],
  ['Metilti Chamba',       'ميتيلي تشامبا',    '260'],
  ['Sujur',                'سوجور',            '228'],
  ['Bir al-Ater',          'بئر العاتر',       '227'],
  ['Ras al-Wadi',          'رأس الوادي',       '247'],
  ['Dirin',                'درين',             '249'],
  ['Sadrata',              'سدراتة',           '253'],
  ['Sidrata',              'سدراتة',           '253'],
  ['Salah',                'صلاح',             '263'],
  ['Rimshi',               'رمشي',             '257'],
  ['Marwana',              'مروانة',           '265'],
  ['Briyan',               'بريان',            '270'],
  ['Tazult Lambi',         'تازولت لامبي',     '277'],
  ['Oulad Djallal',        'أولاد جلال',       '18667'],
  ['Ksar Sbahi',           'Ksar Sbahi',       '19753'],
  ['Sbaa',                 'Sbaa',             '19939'],
  ['El Idrissia',          'El Idrissia',      '19090'],
  ['Maqla',                'مقلع',             '19508'],
  ['Hassasna',             'Hassasna',         '19155'],
  ['Drea',                 'Drea',             '19728'],
  ['Beaulieu',             'Beaulieu',         '15968'],
  ['Zonka',                'Zonka',            '16012'],

  // Misc
  ['As-Saniya',            'السنية',           '231'],
  ['Al-Akhdariya',         'الاخضرية',         '248'],
  ['Al-Hijar',             'الحجار',           '267'],
  ['At-Talaghma',          'التلاغمة',         '256'],
  ['Al-Azba',              'العزباء',          '218'],
  ['Ar-Raghaya',           'الرغاية',          '250'],
  ['Jamaa',                'جامع',             '254'],
  ['Akbu',                 'أكبو',             '233'],
  ['Sidi Khaled',          'سيدي خالد',        '235'],
  ['Qasr Shallala',        'قصر شلالا',        '245'],
  ['Soma',                 'سوما',             '282'],
  ['Sibdu',                'سيبدو',            '280'],
  ['Birin',                'بيرين',            '258'],
  ['Hamam Bouzian',        'همة بوزيان',       '239'],
  ['Ouled Alia',           'Ouled Alia',       '19882'],
  ['Hai Chikhi',           'Haï Chîkhi',       '15066'],
  ['Carcaria',             'الكركرة',          '15984'],
  ['Sidi Ghiles',          'Sidi Ghiles',      '20323'],
];

// ---------------------------------------------------------------------------
// HTTP session with manual cookie handling (dart:io only)
// ---------------------------------------------------------------------------

class HttpSession {
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  final Map<String, String> _cookies = {};

  String get cookieHeader =>
      _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void _storeCookies(HttpClientResponse res) {
    for (final c in res.cookies) {
      _cookies[c.name] = c.value;
    }
  }

  void _applyHeaders(HttpClientRequest req,
      {String? referer, bool xhr = false}) {
    final h = cookieHeader;
    if (h.isNotEmpty) req.headers.set('Cookie', h);
    req.headers
      ..set('User-Agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..set('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8')
      ..set('Accept-Language', 'ar,en-US;q=0.7,en;q=0.3');
    if (referer != null) req.headers.set('Referer', referer);
    if (xhr) req.headers.set('X-Requested-With', 'XMLHttpRequest');
  }

  Future<bool> init() async {
    try {
      final req = await _client.getUrl(Uri.https(kHost, '/'));
      req.followRedirects = true;
      _applyHeaders(req);
      final res = await req.close();
      _storeCookies(res);
      await res.drain<void>();
      return _cookies.containsKey('ci_session');
    } catch (e) {
      print('  ERROR init: $e');
      return false;
    }
  }

  Future<bool> selectCity(String cityId) async {
    try {
      final req = await _client.getUrl(
          Uri.https(kHost, '/index.php/countries/select_city/$cityId'));
      req.followRedirects = false;
      _applyHeaders(req,
          referer: 'https://$kHost/index.php/countries/cities/$kCountryId');
      final res = await req.close();
      _storeCookies(res);
      await res.drain<void>();
      return res.statusCode == 307 || res.statusCode == 302 || res.statusCode == 200;
    } catch (e) {
      print('  ERROR selectCity($cityId): $e');
      return false;
    }
  }

  Future<(int, String)> postEncoded(
      String path, Map<String, String> fields) async {
    try {
      final encoded = fields.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final bytes = utf8.encode(encoded);
      final req = await _client.postUrl(Uri.https(kHost, path));
      req.followRedirects = true;
      _applyHeaders(req, referer: 'https://$kHost/', xhr: true);
      req.headers
        ..set('Content-Type', 'application/x-www-form-urlencoded')
        ..contentLength = bytes.length;
      req.add(bytes);
      final res = await req.close();
      _storeCookies(res);
      final body = await res.transform(utf8.decoder).join();
      return (res.statusCode, body);
    } catch (e) {
      print('  ERROR POST $path: $e');
      return (0, '');
    }
  }

  void close() => _client.close(force: true);
}

// ---------------------------------------------------------------------------
// Site API helpers
// ---------------------------------------------------------------------------

Future<String?> fetchYearHtml(HttpSession s) async {
  for (int attempt = 1; attempt <= 3; attempt++) {
    if (attempt > 1) await Future.delayed(Duration(seconds: attempt * 3));
    final (code, body) =
        await s.postEncoded('/index.php/app/get_year', {'day': kSeedDay});
    if (code == 429) {
      print('  Rate limited (attempt $attempt), waiting...');
      continue;
    }
    if (code != 200 || body.isEmpty) {
      print('  HTTP $code on attempt $attempt');
      continue;
    }

    final t = body.trim();
    if (t.startsWith('{') || t.startsWith('[')) {
      try {
        final data = jsonDecode(t) as Map<String, dynamic>;
        final html = data['html'] as String?;
        if (html != null && html.isNotEmpty) return html;
        print('  Empty html in JSON (attempt $attempt)');
        continue;
      } catch (_) {}
    }
    if (t.contains('<tr') || t.contains('<table')) return t;
    print('  Unexpected body format (attempt $attempt)');
  }
  return null;
}

// ---------------------------------------------------------------------------
// HTML → prayer time rows
// ---------------------------------------------------------------------------

final _timeRe = RegExp(r'^\d{1,2}:\d{2}$');
final _dateRe = RegExp(r'\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{4}');
final _tagRe = RegExp(r'<[^>]+>');

String _strip(String s) => s.replaceAll(_tagRe, '').trim();

List<List<String>> parseYearTable(String html) {
  final rows = <List<String>>[];
  final trRe = RegExp(r'<tr[^>]*>([\s\S]*?)</tr>', caseSensitive: false);
  final tdRe =
      RegExp(r'<t[dh][^>]*>([\s\S]*?)</t[dh]>', caseSensitive: false);

  for (final tr in trRe.allMatches(html)) {
    final cells = tdRe
        .allMatches(tr.group(1)!)
        .map((m) => _strip(m.group(1)!))
        .where((s) => s.isNotEmpty)
        .toList();
    if (cells.isEmpty) continue;

    int dateIdx = cells.indexWhere((c) => _dateRe.hasMatch(c));
    if (dateIdx == -1) continue;

    final times = <String>[];
    for (int i = dateIdx + 1; i < cells.length && times.length < 6; i++) {
      if (_timeRe.hasMatch(cells[i])) times.add(cells[i]);
    }
    if (times.length < 6) continue;

    rows.add([_normDate(cells[dateIdx]), ...times.take(6)]);
  }
  return rows;
}

String _normDate(String raw) {
  final p = raw.split(RegExp(r'[/\-\.]'));
  if (p.length == 3) {
    return '${p[0].padLeft(2, '0')}/${p[1].padLeft(2, '0')}'
        '/${p[2].length == 4 ? p[2] : '20${p[2]}'}';
  }
  return raw;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

Future<void> main() async {
  print('====================================================');
  print('  Algeria Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kAlgeriaCities) {
    final name   = city[0];
    final cityId = city[2];
    print('--- $name ---');

    final session = HttpSession();
    try {
      if (!await session.init()) {
        print('  SKIP: session init failed\n');
        failed++;
        continue;
      }
      await Future.delayed(kRequestDelay);

      final switched = await session.selectCity(cityId);
      print('  selectCity($cityId): ${switched ? "OK" : "failed"}');
      if (!switched) {
        print('  SKIP: could not switch city\n');
        failed++;
        continue;
      }
      await Future.delayed(kRequestDelay);

      print('  Fetching year data...');
      final html = await fetchYearHtml(session);

      if (html == null) {
        print('  FAIL: no data\n');
        failed++;
        continue;
      }

      final rows = parseYearTable(html);
      print('  Parsed ${rows.length} days');

      if (rows.isEmpty) {
        final dbg = 'debug_${name.replaceAll(' ', '_')}.html';
        File(dbg).writeAsStringSync(html);
        print('  WARN: 0 rows — saved $dbg\n');
        failed++;
        continue;
      }

      for (final row in rows) {
        csv.add('$name,${row.join(',')}');
      }
      print('  OK\n');
      ok++;
    } finally {
      session.close();
    }

    await Future.delayed(kCityDelay);
  }

  final outFile = File(kOutputFile);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(csv.join('\n'), encoding: utf8);

  print('====================================================');
  print('  Cities OK     : $ok / ${kAlgeriaCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
