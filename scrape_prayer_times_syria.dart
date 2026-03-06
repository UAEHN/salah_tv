// Syria Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/207
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_syria.dart
//
// Output:
//   assets/csv/syria_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/syria_prayer_times_2026.csv';
const int kCountryId = 207;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Syria Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/207
// ---------------------------------------------------------------------------

const List<List<String>> kSyriaCities = [
  // Major cities
  ['Damascus',          'دمشق',              '9463'],
  ['Aleppo',            'حلب',               '9462'],
  ['Homs',              'حمص',               '9464'],
  ['Hama',              'حماه',              '9465'],
  ['Latakia',           'اللاذقية',          '9466'],
  ['Deir ez-Zor',       'دير الزور',         '9467'],
  ['Tartus',            'طرطوس',             '9474'],
  ['Al-Hasakah',        'الحسكة',            '9476'],
  ['Daraya',            'داريا',             '9477'],
  ['Manbij',            'منبج',              '9478'],
  ['Jableh',            'جبلة',              '9479'],
  ['Abu Kamal',         'ابو كمال',          '9480'],
  ['Al-Mayadin',        'الميادين',          '9482'],
  ['Al-Rastan',         'الرستن',            '9483'],
  ['Tadmur',            'تدمر',              '9484'],
  ['Al-Nabk',           'النبك',             '9485'],
  ['Khan Shaykhun',     'خان شيخون',         '9486'],
  ['Afrin',             'عفرين',             '9487'],
  ['Arib',              'عربين',             '9488'],
  ['Al-Qusayr',         'القصير',            '9489'],
  ['Yabrud',            'يبرود',             '9490'],
  ['Jisr Al-Shughur',   'جسر الشغور',        '9491'],
  ['Bani Yas',          'بني ياس',           '9492'],
  ['Telbisseh',         'تلبيسة',            '9493'],
  ['Harasta Al-Basal',  'حرستا البصل',       '9494'],
  ['Tadif',             'تاديف',             '9496'],
  ['Saraqib',           'سراقب',             '9497'],
  ['Jairud',            'جيرود',             '9498'],
  ['Masyaf',            'مصياف',             '9499'],
  ['Maaret Misrin',     'معرة مصر',          '9500'],
  ['Al-Qaryatain',      'القريتين',          '9501'],
  ['Salqin',            'سلقين',             '9502'],
  ['Souran',            'سوران',             '9504'],
  ['Bansh',             'بنش',               '9505'],
  ['Al-Qassim',         'القصيم',            '9506'],
  ['Tel Kalakh',        'تل كلخ',            '9507'],
  ['Al-Zabadani',       'الزبداني',          '9508'],
  ['Tayba Al-Imam',     'طيبة الإمام',       '9509'],
  ['Hagin',             'هاجين',             '9510'],
  ['Inkhil',            'انخل',              '9511'],
  ['Deir Hafer',        'دير حافر',          '9512'],
  ['Safita',            'صافيتا',            '9513'],
  ['Sheikh Miskeen',    'الشيخ مسكين',       '9514'],
  ['Kafr Sunamayn',     'ك سناماين',         '9515'],
  ['Tel Al-Rif',        'تل الريف',          '9516'],
  ['Nobel',             'نوبل',              '9517'],
  ['Sabikhan',          'صبيخان',            '9518'],
  ['Jarabulus',         'جرابولوس',          '9519'],
  ['Kafr Nabal',        'كفر نابل',          '9520'],
  ['Al-Haraq',          'الحراق',            '9521'],
  ['Al-Kiswa',          'الكسوة',            '9522'],
  ['Halfaya',           'حلفايا',            '9523'],
  ['Kafr Takharim',     'كفر تخريم',         '9524'],
  ['Al-Dana',           'الدانة',            '9525'],
  ['Kafr Zeta',         'كفر زيتا',          '9526'],
  ['Kafr Laha',         'كفر لاها',          '9527'],
  ['Darbasiyah',        'درباسية',           '9528'],
  ['Qara',              'قارة',              '9529'],
  ['Qatana',            'قطنا',              '9530'],
  ['Al-Qatifa',         'القطيفة',           '9531'],
  ['Izra',              'ايزرا',             '9532'],
  ['Salkhad',           'سلخيد',             '9533'],
  ['Drekish',           'دريكيش',            '9534'],
  ['Makram Al-Fuqani',  'مكرم الفوقاني',     '9535'],
  ['Maaloula',          'معلولا',            '9536'],
  ['Bosra Al-Sham',     'بصرى الشام',        '9537'],
  ['Idlib',             'ادلب',              '9470'],
  ['Al-Bab',            'الباب',             '9469'],
  ['Al-Thawra',         'الثورة',            '9475'],
  ['Salamiyah',         'سلمية',             '9473'],
  ['Douma',             'دوما',              '9471'],
  ['Kafr Safrah',       'ك سفيرة',           '9472'],
  ['Fi Al-Tel',         'في التل',           '9481'],

  // Additional cities
  ['Al-Ayyubiyah',      'الأيوبية',          '13635'],
  ['Al-Hajjar Al-Aswad','الحجر الأسود',       '18922'],
  ['Al-Harak',          'الحراك',            '20104'],
  ['Al-Shaghur',        'الشاغور',           '13660'],
  ['Al-Sherkassiah',    'الشركسية',          '13689'],
  ['Al-Sheikh Saad',    'الشيخ سعد',         '13675'],
  ['Al-Qahutaniyah',    'القحطانية',         '16307'],
  ['Bab Bella',         'باب بيلا',          '20119'],
  ['Jaramana',          'جرمانا',            '14380'],
  ['Homs Alt',          'حمص',               '11053'],
  ['Dasagha',           'دساغة',             '13633'],
  ['Deir Al-Balad',     'دمر البلد',         '11525'],
  ['Amuda',             'عامودا',            '16343'],
  ['Qadsiyah',          'قدسيا',             '15620'],
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
  print('  Syria Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kSyriaCities) {
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
  print('  Cities OK     : $ok / ${kSyriaCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
