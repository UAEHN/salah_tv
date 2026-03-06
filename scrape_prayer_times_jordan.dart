// Jordan Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/108
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_jordan.dart
//
// Output:
//   assets/csv/jordan_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/jordan_prayer_times_2026.csv';
const int kCountryId = 108;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Jordan Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/108
// ---------------------------------------------------------------------------

const List<List<String>> kJordanCities = [
  // Major governorate capitals & large cities
  ['Amman',             'عمان',                    '50183'],
  ['Irbid',             'اربد',                    '50184'],
  ['Zarqa',             'الزرقاء',                 '50258'],
  ['Aqaba',             'العقبة',                  '50187'],
  ['Salt',              'السلط',                   '50189'],
  ['Madaba',            'مادبا',                   '50188'],
  ['Karak',             'الكرك',                   '50252'],
  ['Tafilah',           'الطفيلة',                 '50196'],
  ['Jerash',            'جرش',                     '50195'],
  ['Ajloun',            'عجلون',                   '50186'],
  ['Al Mafraq',         'المفرق',                  '50191'],
  ['Al Ramtha',         'الرمثا',                  '50190'],
  ['Al Jubaiha',        'الجبيهة',                 '50192'],
  ['Sahab',             'سحاب',                    '50193'],
  ['Al Quwaysma',       'القويسمة',                '50194'],
  ['Al Tafila',         'الطفيلة',                 '50196'],

  // Northern region
  ['Umm Qais',          'أم قيس',                  '50245'],
  ['Adeir',             'ادير',                    '50242'],
  ['Al Basira',         'البصيرة',                 '50219'],
  ['Northern Al Bunyat','البنيات الشمالية',         '50229'],
  ['Al Halawa',         'الحلاوة',                 '50232'],
  ['Al Kharja',         'الخارجة',                 '50231'],
  ['Al Rabah',          'الرباح',                  '50247'],
  ['Al Zahar',          'الزهار',                  '50249'],
  ['Al Shajara',        'الشجرة',                  '50207'],
  ['Al Qasr',           'القصر',                   '50250'],
  ['Al Kutta',          'الكتة',                   '50228'],
  ['Al Kariama',        'الكريمة',                 '50201'],
  ['Al Mazar North',    'المزار',                  '50213'],
  ['Umm Al Qitain',     'ام القطين',               '50248'],
  ['Aydon',             'ايدون',                   '50199'],
  ['Balila',            'باليلا',                  '50237'],
  ['Bait Yafa',         'بيت يافا',                '50216'],
  ['Tibna',             'تبنة',                    '50236'],
  ['Jawa',              'جاوا',                    '50208'],
  ['Hatim',             'حاتم',                    '50230'],
  ['Deir Yousef',       'دير يوسف',                '50225'],
  ['Rimmon',            'ريمون',                   '50226'],
  ['Sakib',             'ساكب',                    '50210'],
  ['Sal',               'سال',                     '50222'],
  ['Sabha',             'سبها',                    '50233'],
  ['Sakhrah',           'صخرة',                    '50209'],
  ['Anjara',            'عنجرة',                   '50202'],
  ['Qafqafa',           'قفقفا',                   '50243'],
  ['Qir Maaf',          'قير معاف',                '50198'],
  ['Kafr Abl',          'كفر أبل',                 '50224'],
  ['Kafr Asad',         'كفر اسد',                 '50215'],
  ['Kafr Saum',         'كفر صوم',                 '50220'],
  ['Kiytim',            'كيتيم',                   '50234'],
  ['Malka',             'مالكا',                   '50223'],
  ['Waqqas',            'وقاص',                    '50227'],
  ['Yerka',             'يركا',                    '50239'],
  ['Hakma',             'حكما',                    '50221'],
  ['Judita',            'جديتا',                   '50206'],
  ['Sawf',              'سوف',                     '50205'],
  ['Suma',              'صما',                     '50214'],
  ['Ein Jenah',         'عين جنة',                 '50211'],
  ['Ay',                'عي',                      '50218'],
  ['In Tayba',          'في طيبة',                 '50246'],

  // Central / Amman region
  ['Dabouq',            'دابوق',                   '50182'],
  ['Al Maamora',        'المعمورة',                '50181'],
  ['Al Karamah',        'الكرامة',                 '50212'],
  ['Abu Nusair Housing','إسكان ابو نصير',           '50265'],
  ['Abu Hamid',         'ابو حامد',                '50271'],
  ['Bab Amman',         'باب عمان',                '50261'],
  ['Al Baaj',           'الباعج',                  '50260'],
  ['Al Batin',          'البطين',                  '50264'],
  ['Al Juwayda',        'الجويدة',                 '50275'],
  ['Al Rabia',          'الرابية',                 '50290'],
  ['Al Saro',           'السرو',                   '50268'],
  ['Al Abdali',         'العبدلي',                 '50270'],
  ['Ain Al Basha',      'عين الباشا',              '50287'],
  ['Al Tayba Al Karak', 'الطيبة الكرك',            '50235'],
  ['Al Tara',           'الطرة',                   '50203'],
  ['Suburan Al Shorouq','ضاحية الشروق',            '50291'],
  ['Sama',              'سما',                     '50269'],
  ['Salhoub',           'سلحوب',                   '50303'],
  ['Safout',            'صافوط',                   '50311'],

  // Zarqa / Eastern region
  ['Al Dhalil',         'الضليل',                  '50254'],
  ['Al Shawish District','حي الشاويش',             '50259'],
  ['Al Fayha District', 'حي الفيحاء',              '50256'],
  ['Al Shafa District', 'حي الشفا',                '50255'],
  ['South Al Rawda District', 'حي الروضة الجنوبي', '50263'],
  ['Armed Forces Housing','اسكان القوات المسلحة',  '50262'],
  ['Al Jatha',          'الجثة',                   '50279'],
  ['Al Hadba',          'الحدبة',                  '50299'],
  ['Al Hadib',          'الحديب',                  '50312'],
  ['Al Dibab',          'الدباب',                  '50301'],
  ['Al Dukhila',        'الدوخيلة',                '50289'],
  ['Al Salaalim',       'السلالم',                 '50282'],
  ['Al Ayis',           'العيس',                   '50302'],
  ['Al Mazar Zarqa',    'المزار',                  '50276'],
  ['Al Mafraq Zarqa',   'المفرق',                  '50273'],
  ['Burma',             'بورما',                   '50240'],
  ['Beit Adis',         'بيت اديس',                '50241'],
  ['Prince Muhammad District','حي الأمير محمد',    '50253'],
  ['Al Baraka District','حي البركة',               '50285'],
  ['Al Barnis District','حي البرنيس',              '50281'],
  ['Al Habashnah District','حي الحباشنة',          '50300'],
  ['Al Doha District',  'حي الدوحة',               '50308'],
  ['Central Al Rawda',  'حي الروضة الاوسط',        '50293'],
  ['North Al Rawda',    'حي الروضة الشمالي',       '50284'],
  ['Al Zahra District', 'حي الزهراء',              '50304'],
  ['Al Shuwayka District','حي الشويكة',            '50292'],
  ['Al Aqayla District','حي العقايلة',             '50295'],
  ['Al Fadhila District','حي الفضيلة',             '50306'],
  ['Al Mattal District','حي المطل',                '50286'],
  ['Al Manara District','حي المنارة',              '50305'],
  ['Jafar District',    'حي جعفر',                 '50294'],
  ['Misyoun District',  'حي ميسلون',               '50272'],
  ['Abu Bakr District', 'حي ابو بكر',              '50274'],
  ['Ibn Awf District',  'حي ابن عوف',              '50204'],
  ['Al Boutas Housing', 'اسكان البوتاس',           '50283'],
  ['Al Baqaan',         'البقعان',                 '50297'],
  ['Al Thughra',        'الثغرة',                  '50307'],
  ['Al Hamma',          'الحمة',                   '50288'],
  ['New Al Humayma',    'الحميمة الجديدة',         '50277'],
  ['Eastern District',  'الحي الشرقي',             '50280'],
  ['Southern Al Shunah','الشونة الجنوبية',         '50298'],
  ['Hajaj City',        'مدينة الحجاج',            '50296'],
  ['Marud',             'مرود',                    '50310'],
  ['Tabaa',             'طباعة',                   '50314'],
  ['Saul',              'سول',                     '50313'],
  ['Ouhayda',           'أوهيدة',                  '50278'],
  ['Umm Al Samaq',      'أم السماق',               '50200'],

  // Southern region
  ['Al Jafr',           'الجفر',                   '50251'],
  ['Al Giza',           'الجيزة',                  '50244'],
  ['Al Quwayra',        'القويرة',                 '50217'],
  ['Al Qaim',           'القيم',                   '50238'],
  ['Petra',             'بترا',                    '50266'],
  ['Aqaba South',       'العقبة',                  '50267'],

  // Other / unclassified
  ['Al Mantara',        'Al Manţarah',             '50309'],
  ['Alherafya',         'Alherafya',               '50257'],
  ['Wadi Kasr Al Sair', 'وادي ك السير',            '50185'],
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
  print('  Jordan Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kJordanCities) {
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
  print('  Cities OK     : $ok / ${kJordanCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
