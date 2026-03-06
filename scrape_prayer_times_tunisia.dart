// Tunisia Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/217
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_tunisia.dart
//
// Output:
//   assets/csv/tunisia_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/tunisia_prayer_times_2026.csv';
const int kCountryId = 217;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Tunisia Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/217
// ---------------------------------------------------------------------------

const List<List<String>> kTunisiaCities = [
  // Major cities
  ['Tunis',                'تونس',                '9828'],
  ['Sousse',               'سوسة',                '9830'],
  ['Sfax',                 'صفاقس',               '9829'],
  ['Bizerte',              'بنزرت',               '9833'],
  ['Al Qayrawan',          'القيروان',            '9832'],
  ['Al Qassareen',         'القصرين',             '9835'],
  ['Qafsa',                'قفصة',                '9836'],
  ['Jerba',                'جرجيس',               '9838'],
  ['Al Munastir',          'المنستير',            '9839'],
  ['Al Muhammadiya',       'المحمدية',            '9840'],
  ['Al Marsa',             'المرسى',              '9841'],
  ['Msaken',               'مساكن',               '9842'],
  ['Siqanes',              'سقانس',               '9843'],
  ['Houma al Souq',        'حومة السوق',          '9844'],
  ['Tataouine',            'تطاوين',              '9845'],
  ['Duan',                 'دوان',                '9846'],
  ['Beja',                 'بجا',                 '9847'],
  ['Al Hammamat',          'الحمامات',            '9848'],
  ['Jendouba',             'جندوبة',              '9849'],
  ['Al Kaf',               'الكاف',               '9850'],
  ['Hamam al Anf',         'حمام الأنف',          '9851'],
  ['Wad Lil',              'واد ليل',             '9852'],
  ['Rades',                'رادس',                '9855'],
  ['Sidi Bouzid',          'سيدي بوزيد',          '9856'],
  ['Al Mutlawi',           'المتلاوي',            '9857'],
  ['Jamal',                'جمال',                '9858'],
  ['Qasr Hallal',          'قصر هلال',            '9859'],
  ['Al Hamma',             'الحمة',               '9860'],
  ['Tozeur',               'توزر',                '9861'],
  ['Dar Shaaban',          'دار شعبان',           '9862'],
  ['Hamam Sousse',         'حمام سوسة',           '9863'],
  ['Al Qarmada',           'القرمدة',             '9864'],
  ['Al Kurba',             'الكوربة',             '9865'],
  ['La Cebala du Morning', 'السيبالة دو موران',   '9866'],
  ['Mater',                'ماطر',                '9867'],
  ['Al Radif',             'الرديف',              '9868'],
  ['Douz',                 'دوز',                 '9869'],
  ['Qusur Assaf',          'قصور عساف',           '9870'],
  ['Slyane',               'سليانة',              '9871'],
  ['Manouba',              'منوبة',               '9872'],
  ['Nefta',                'نفطة',                '9873'],
  ['Shebaa',               'شبعا',                '9874'],
  ['Manzel Jamil',         'منزل جميل',           '9875'],
  ['Taklassa',             'تكلاسة',              '9876'],
  ['Majaz al Bab',         'مجاز الباب',          '9877'],
  ['Akuda',                'أكودا',               '9879'],
  ['Qabili',               'قبيلي',               '9880'],
  ['Tajouine',             'تاجوين',              '9881'],
  ['Douar Tanja',          'دوار طنجة',           '9882'],
  ['Al Wardanin',          'الوردانين',           '9883'],
  ['Al Fass',              'الفص',                '9884'],
  ['Beni Khiyar',          'بني خيار',            '9885'],
  ['Zaghouan',             'زغوان',               '9886'],
  ['Manzel Bzalafa',       'المنزل بزلافة',       '9887'],
  ['Al Alya',              'العليا',              '9888'],
  ['Tala',                 'تالا',                '9889'],
  ['Al Baqliyya',          'البقليطة',            '9890'],
  ['Manzel Abdel Rahman',  'منزل عبد الرحمن',     '9891'],
  ['Maktar',               'مكتر',                '9892'],
  ['Sahlin',               'ساحلين',              '9893'],
  ['Qas al Sayada',        'قاص الصيادة',         '9894'],
  ['Al Tastour',           'التاستور',            '9896'],
  ['Ben Gardane',          'بن قردان',            '9897'],
  ['Taboris',              'تبورس',               '9898'],
  ['Benbala',              'بنبالة',              '9899'],
  ['Bou Arada',            'بو عرادة',            '9900'],
  ['Qassib al Midiouini',  'قصيب المديوني',       '9901'],
  ['Beni Khallad',         'بني خلاد',            '9902'],
  ['Qama Sares',           'قاما سارس',           '9903'],
  ['Qafour',               'قعفور',               '9904'],
  ['Bu Urqub',             'بو أرقوب',            '9905'],
  ['Al Sakhira',           'الصخيرة',             '9907'],
  ['Sidi Bou Ali',         'سيدي بو علي',         '9908'],
  ['Manzel Kamel',         'منزل كامل',           '9909'],
  ['Beni Hasan',           'بني حسن',             '9910'],
  ['Dijash',               'ديجاش',               '9911'],
  ['Qas Sund',             'قاص سند',             '9912'],
  ['Haffouz',              'حفوز',                '9913'],
  ['Al Kuraib',            'الكريب',              '9914'],
  ['Al Jibaniya',          'الجبانية',            '9915'],
  ['Al Jilaa',             'الجلاء',              '9916'],
  ['Sabikha',              'سبيخة',               '9917'],
  ['Sidi Oulouan',         'سيدي أولوان',         '9918'],
  ['Al Maamura',           'المعمورة',            '9919'],
  ['Al Harqala',           'الحرقلة',             '9920'],
  ['Al Raqb',              'الرقب',               '9921'],
  ['Zaouia Jdidi',         'زاوية الجديدي',       '9922'],
  ['Saqiyat Sidi Youssuf', 'ساقية سيدي يوسف',    '9923'],
  ['Melouliche',           'ملوليش',              '9924'],
  ['Shouorban',            'شوربان',              '9925'],
  ['Sabiba',               'سبيبا',               '9926'],
  ['Jimna',                'جيمنا',               '9927'],
  ['Tabarka',              'طبرقة',               '9895'],
  ['Gafsa',                'قابس',                '9834'],
  ['La Goulet',            'لا جوليت',            '9837'],
  ['Al Jum',               'الجم',                '9878'],
  ['Zouila',               'زويلا',               '9854'],
  ['Midoun',               'ميدون',               '9831'],
  ['Rafraf',               'رفراف',               '9906'],

  // Additional cities
  ['Nabul',                'نابل',                '15259'],
  ['Manzel Bourguiba',     'منزل بورقيبة',        '13979'],
  ['La Pecherie',          'الصيادية',            '13289'],
  ['Al Markaz al Omrani',  'المركز العمراني الشمالي','15137'],
  ['Al Nafida',            'النفيضة',             '19975'],
  ['Megrine',              'مقرين',               '19744'],
  ['Fouchana',             'فوشانة',              '19888'],
  ['Douar Goungla',        'دوار قونقلة',         '18641'],
  ['Bir Belhssen',         'بير بلحسن',           '19974'],
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
  print('  Tunisia Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kTunisiaCities) {
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
  print('  Cities OK     : $ok / ${kTunisiaCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
