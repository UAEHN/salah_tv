// Egypt Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/63
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_egypt.dart
//
// Output:
//   assets/csv/egypt_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/egypt_prayer_times_2026.csv';
const int kCountryId = 63;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Egypt Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/63
// ---------------------------------------------------------------------------

const List<List<String>> kEgyptCities = [
  // Major cities
  ['Cairo',                   'القاهرة',              '10705'],
  ['Alexandria',              'الإسكندرية',           '10706'],
  ['Giza',                    'الجيزة',               '10705'],
  ['Luxor',                   'الأقصر',               '10709'],
  ['Aswan',                   'أسوان',                '10718'],
  ['Assiut',                  'أسيوط',                '10711'],
  ['Port Said',               'بور سعيد',             '10707'],
  ['Suez',                    'السويس',               '10708'],
  ['Tanta',                   'طنطا',                 '10710'],
  ['Mansoura',                'منصورة',               '10712'],
  ['Sohag',                   'سوهاج',                '10714'],
  ['Damietta',                'دمياط',                '10715'],
  ['Damanhour',               'دمنهور',               '10716'],
  ['Zagazig',                 'الزقازيق',             '10717'],
  ['El-Arish',                'العريش',               '10722'],
  ['Rosetta',                 'رشيد',                 '10724'],
  ['Kafr El-Sheikh',          'كفر الشيخ',            '10725'],
  ['Edfu',                    'إدفو',                 '10726'],
  ['Qena',                    'قنا',                  '10728'],
  ['Marsa Matruh',            'مرسى مطروح',           '10729'],
  ['Beni Suef',               'بني سويف',             '10730'],
  ['Benha',                   'بنها',                 '10731'],
  ['Minya',                   'المنيا',               '10732'],
  ['Girga',                   'جرجا',                 '10735'],
  ['Esna',                    'إسنا',                 '10736'],
  ['Disouq',                  'دسوق',                 '10737'],
  ['Dekernes',                'دكرنس',                '10738'],
  ['Qalyub',                  'قليوب',                '10739'],
  ['Nag Hammadi',             'نجع حمادى',            '10740'],
  ['Menouf',                  'منوف',                 '10741'],
  ['Melouay',                 'ملوي',                 '10742'],
  ['Kom Ombo',                'كوم امبو',             '10743'],
  ['Bilbeis',                 'بلبيس',                '10745'],
  ['El-Kharga',               'الخارجة',              '10747'],
  ['El-Hawamdia',             'الحوامدية',            '10748'],
  ['Akhmim',                  'أخميم',                '10749'],
  ['New Cairo',               'القاهرة الجديدة',      '10751'],
  ['Abnoub',                  'أبنوب',                '10752'],
  ['Zifta',                   'زفتى',                 '10753'],
  ['Tahta',                   'طهطا',                 '10756'],
  ['Tukh',                    'طوخ',                  '10754'],
  ['Tela',                    'تلا',                  '10755'],
  ['Shebin El-Qanater',       'شبين القناطر',         '10758'],
  ['Samalout',                'سمالوط',               '10760'],
  ['Edko',                    'إدكو',                 '10761'],
  ['Ibshawai',                'إبشواي',               '10762'],
  ['Fareskor',                'فارسكور',              '10765'],
  ['Faqous',                  'فاقوس',                '10766'],
  ['Dairb Nigm',              'ديرب نجم',             '10767'],
  ['Disna',                   'دشنا',                 '10768'],
  ['Dairut',                  'ديروط',                '10769'],
  ['Qous',                    'قوص',                  '10770'],
  ['Menyet El-Nasr',          'منية النصر',           '10771'],
  ['Menfaloute',              'منفلوط',               '10772'],
  ['El-Qanater El-Khairia',   'القناطر الخيرية',      '10746'],
  ['Belqas',                  'بلقاس',                '10744'],
  ['El-Fashn',                'الفشن',                '10786'],
  ['Fayoum',                  'الفيوم',               '10721'],
  ['Ismailia',                'مدينة الإسماعيلية',    '10719'],
  ['Shebin El-Kom',           'شبين الكوم',           '10723'],
  ['Kafr El-Dawar',           'كفر الدوار',           '10734'],
  ['Fouh',                    'فوة',                  '10764'],
  ['Sherbin',                 'شربين',                '10757'],
  ['Ausim',                   'أوسيم',                '10776'],
  ['Ashmoun',                 'أشمون',                '10778'],
  ['El-Qarin',                'القوصية',              '10780'],
  ['El-Mataria',              'المطرية',              '10781'],
  ['El-Manzala',              'المنزلة',              '10782'],
  ['El-Mansha',               'المنشاه',              '10783'],
  ['El-Tel El-Kebir',         'التل الكبير',          '10777'],
  ['El-Jamalia',              'الجمالية',             '10785'],
  ['El-Zerqa',                'الزرقا',               '10789'],
  ['Abu Teej',                'أبو تيج',              '10787'],
  ['Abu Qirqas',              'أبو قرقاص',            '10788'],
  ['Abu al-Matamir',          'أبو المتامير',         '10790'],
  ['Tamiya',                  'طامية',                '10791'],
  ['Sidi Salem',              'سيدي سالم',            '10792'],
  ['Juhaynah',                'جهينة',                '10793'],
  ['Hehia',                   'ههيا',                 '10794'],
  ['Farshut',                 'فرشوط',                '10795'],
  ['Deir Mawas',              'دير مواس',             '10796'],
  ['Bush',                    'بوش',                  '10797'],
  ['Quwisna',                 'قويسنا',               '10798'],
  ['Motai',                   'مطاي',                 '10799'],
  ['Mashtul as-Suq',          'مشتول السوق',          '10800'],
  ['6th of October City',     'مدينة السادس من أكتوبر','10801'],
  ['El-Shohada',              'الشهداء',              '10802'],
  ['El-Qanayyat',             'القنايات',             '10803'],
  ['El-Hamoul',               'الحامول',              '10804'],
  ['Al-Balyania',             'البليانة',             '10805'],
  ['Al-Badari',               'البادري',              '10806'],
  ['El-Delenjat',             'الدلنجات',             '10807'],
  ['Ain El-Sokhna',           'العين السخنة',         '10808'],
  ['Itsa',                    'إطسا',                 '10809'],
  ['Tenth of Ramadan',        'العاشر من رمضان',      '11368'],
  ['Mit Selsail',             'ميت سلسيل',            '11265'],
  ['Sammanoud',               'سمنود',                '11305'],
  ['Damshit',                 'دمشيت',                '12564'],
  ['Kafr Essam',              'كفر عصام',             '13078'],
  ['Birmbal El-Qadima',       'برمبال القديمة',       '16145'],
  ['Tahret Hamid',            'طهرة حميد',            '16523'],
  ['Qaryat El-Shemali',       'قرية الشمالي',         '18528'],
  ['Beni Workan',             'بني وركان',            '18203'],
  ['Maadi',                   'المعادي',              '20108'],
  ['Helwan',                  'حلوان',                '20085'],
  ['El-Mahalla El-Kubra',     'المحلة الكبرى',        '20093'],
  ['Hurghada',                'الغردقة',              '20124'],
  ['Basyun',                  'باسيون',               '20123'],
  ['Arab El-Raml',            'عرب الرمل',            '20127'],
  ['Al-Asifar',               'الأصيفر',              '19513'],
  ['Talkhah',                 'طلخا',                 '19592'],
  ['Ezbet El-Salga',          'عزبة السلجا',          '19493'],
  ['Ezbet El-Sharifiya',      'عزبة الشريفية',        '20107'],
  ['Ezbet el-Insha',          'عزبة الإنشاء',         '20238'],
  ['Bandar al-Mansurah',      'بندر المنصورة',        '18014'],
  ['Damat',                   'دمات',                 '19108'],
  ['Madinet el-Nasr',         'مدينة النصر',          '19834'],
  ['Menyet Samnoude',         'منية سمنود',           '20196'],
  ['El-Qoussiya',             'القوصية',              '10779'],
  ['Shabra Bakhoom',          'شبرا بخوم',            '17588'],
  ['Mahallet Damana',         'محلة دمنة',            '17189'],
  ['Birmbal El-Qadima',       'برمبال القديمة',       '16145'],
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
  print('  Egypt Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kEgyptCities) {
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
  print('  Cities OK     : $ok / ${kEgyptCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
