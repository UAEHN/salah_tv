// Palestine Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/164
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_palestine.dart
//
// Output:
//   assets/csv/palestine_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/palestine_prayer_times_2026.csv';
const int kCountryId = 164;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Palestine Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/164
// ---------------------------------------------------------------------------

const List<List<String>> kPalestineCities = [
  // Major cities
  ['Jerusalem',                'القدس',                      '5206'],
  ['East Jerusalem',           'القدس الشرقية',              '10568'],
  ['Gaza',                     'غزة',                        '10569'],
  ['Nablus',                   'نابلس',                      '10572'],
  ['Hebron',                   'الخليل',                     '10571'],
  ['Ramallah',                 'رام الله',                   '13881'],
  ['Jenin',                    'جنين',                       '10576'],
  ['Tulkarem',                 'طولكرم',                     '10573'],
  ['Qalqilya',                 'قلقيلية',                    '10574'],
  ['Jericho',                  'أريحا',                      '10577'],
  ['Salfit',                   'سلفيت',                      '10583'],
  ['Tubas',                    'طوباس',                      '10580'],
  ['Khan Yunis',               'خان يونس',                   '10570'],
  ['Al-Bireh',                 'البيرة',                     '10575'],
  ['Beitunya',                 'بيتونيا',                    '13194'],

  // West Bank cities & towns
  ['Az-Zahiriyya',             'الظاهرية',                   '10578'],
  ['Idna',                     'إذنا',                       '10579'],
  ['Yabad',                    'يعبد',                       '10581'],
  ['Sourif',                   'صوريف',                      '10582'],
  ['Jab\'a',                   'جبع',                        '10584'],
  ['Za\'tara',                 'زعترة',                      '10586'],
  ['Aqraba',                   'عقربا',                      '10585'],
  ['Qibya',                    'قبيه',                       '10587'],
  ['Al-Jiftlik',               'الجفتلك',                    '10588'],
  ['Hejja',                    'حجة',                        '10589'],
  ['Jalbon',                   'جلبون',                      '10590'],
  ['Al-Mughayyir',             'المغير',                     '10591'],
  ['Rafat',                    'رافات',                      '10592'],
  ['Al-Hadhalyin',             'الهذالين',                   '10593'],
  ['Beit Nuba',                'بيت نوبا',                   '10594'],
  ['Al-Farsiyya',              'الفارسية',                   '10595'],
  ['Arab ar-Rashayida',        'عرب الرشايدة',               '10596'],
  ['Turqumiya',                'ترقوميا',                    '13729'],
  ['Dura Qar\'a',              'دورا قرع',                   '13367'],
  ['Ras al-Amud',              'راس العامود',                '13703'],
  ['Barham',                   'برهام',                      '13728'],
  ['Zahrat an-Nada',           'ظهرة الندى',                 '18794'],
  ['Arab al-Jahaleen',         'عرب الجهالين',               '16099'],
  ['Abu Madin',                'ابو مدين',                   '18274'],
  ['Al-Ram & Dahiyat al-Bareed','الرام وضاحية البريد',       '15964'],
  ['As-Salam',                 'السلام',                     '13850'],
  ['Sheikh Radwan',            'الشيخ رضوان',                '13664'],
  ['Al-Fuwayda',               'الفوايدة',                   '17665'],
  ['City of Return',           'مدينة العودة',               '13665'],
  ['Al-Fawaqah Quarter',       'حي الفواقا',                 '16400'],
  ['Dar Jaresh Quarter',       'حي دار جريس',                '19395'],
  ['Tarama',                   'طرامة',                      '19510'],
  ['An Nazlah',                'An Nazlah',                  '18391'],

  // Arab cities inside Israel (48 territories)
  ['Haifa',                    'حيفا',                       '5208'],
  ['Tel Aviv-Jaffa',           'تل أبيب-يافا',               '5207'],
  ['Beersheba',                'بئر السبع',                  '5211'],
  ['Nazareth',                 'الناصرة',                    '5224'],
  ['Acre',                     'عكا',                        '5229'],
  ['Lod',                      'اللد',                       '5222'],
  ['Netanya',                  'نتانيا',                     '5212'],
  ['Ramla',                    'الرملة',                     '5224'],
  ['Ashdod',                   'أشدود',                      '5209'],
  ['Ashkelon',                 'عسقلان',                     '5217'],
  ['Herzliya',                 'هرتسليا',                    '5218'],
  ['Kfar Sava',                'كفار سافا',                  '5219'],
  ['Nahariya',                 'نهاريا',                     '5225'],
  ['Umm al-Fahm',              'ام الفحم',                   '5232'],
  ['Tiberias',                 'طبريا',                      '5233'],
  ['Ramat Gan',                'رمات غان',                   '5216'],
  ['At-Taiba',                 'الطيبة',                     '5239'],
  ['Zefat',                    'زفات',                       '5242'],
  ['Sakhnin',                  'سخنين',                      '5246'],
  ['Holon',                    'حولون',                      '5213'],
  ['Bnei Brak',                'بني براق',                   '5214'],
  ['Bat Yam',                  'بات يام',                    '5215'],
  ['Beit Shemesh',             'بيت شيمش',                   '5221'],
  ['Kiryat Gat',               'كريات جات',                  '5228'],
  ['Rishon LeZion',            'ريشون لتسיון',               '5210'],
  ['Yavne',                    'يفنه',                       '5240'],
  ['Dimona',                   'ديمونة',                     '5238'],
  ['Eilat',                    'إيلات',                      '5230'],
  ['Ramat Hasharon',           'رمات هشارون',                '5237'],
  ['Kiryat Ata',               'كريات آتا',                  '5226'],
  ['Kiryat Bialik',            'كريات بياليك',               '5236'],
  ['Kiryat Motzkin',           'كريات موتسكين',              '5234'],
  ['Kiryat Yam',               'كريات يام',                  '5235'],
  ['Kiryat Shmona',            'كريات شمونة',                '5249'],
  ['Daliyat al-Karmel',        'دالية الكرمل',               '5245'],
  ['Tamra',                    'طمرة',                       '5244'],
  ['Tirat al-Carmel',          'طيرة الكرمل',                '5253'],
  ['Mughar',                   'مغار',                       '5254'],
  ['Kafr Kanna',               'كفر كنا',                    '5255'],
  ['Al-Jadida',                'الجديدة',                    '5256'],
  ['Kafr Qasem',               'كفر قاسم',                   '5257'],
  ['Qalansawe',                'قلنسوة',                     '5258'],
  ['Reina',                    'رينا',                       '5259'],
  ['Kafr Manda',               'كفر مندا',                   '5260'],
  ['Gan Yavne',                'غان يفنه',                   '5261'],
  ['Jidera',                   'جيدرا',                      '5262'],
  ['Jisr az-Zarqa',            'جن تقوى',                    '5264'],
  ['Iksal',                    'ايكسال',                     '5265'],
  ['Al-Jadida',                'الجديدة',                    '5256'],
  ['Azur',                     'ازور',                       '5266'],
  ['An-Nahl',                  'النهف',                      '5267'],
  ['Beit Jann',                'بيت جن',                     '5268'],
  ['Al-Fureidis',              'الفريديس',                   '5269'],
  ['Kabul',                    'كابول',                      '5270'],
  ['Giv\'at Ye\'arim',         'حتى يهودا',                  '5271'],
  ['Tel Mond',                 'تل موند',                    '5272'],
  ['Yeroham',                  'ياروهام',                    '5273'],
  ['Rekhasim',                 'Rekhasim',                   '5274'],
  ['Deburiyya',                'دبوريه',                     '5277'],
  ['Bani Ayash',               'بني عايش',                   '5279'],
  ['Jibjiyya',                 'جلجولية',                    '5280'],
  ['Bir al-Maksur',            'بئر المكسور',                '5281'],
  ['Bardisiyya',               'برديسيا',                    '5282'],
  ['Lehavim',                  'ليهافيم',                    '5283'],
  ['Abu Ghosh',                'ابو غوش',                    '5284'],
  ['Shlomi',                   'شلومي',                      '5285'],
  ['Kfar Vardim',              'كفار وراديم',                '5286'],
  ['Beit Dagan',               'بيت داغان',                  '5287'],
  ['Ramat Yishai',             'رمات يشاي',                  '5288'],
  ['Horvash',                  'هورفيش',                     '5289'],
  ['Al-Yakin',                 'الياكين',                    '5296'],
  ['Fassouta',                 'فاسوتا',                     '5295'],
  ['Sheikh Danoun',            'الشيخ دنون',                 '5302'],
  ['Al-Jesh',                  'الجش',                       '5297'],
  ['Ozer',                     'أوزير',                      '5298'],
  ['Rosh Pina',                'روش بينا',                   '5299'],
  ['Sulam',                    'سولام',                      '5300'],
  ['Kafr Tavor',               'كفر تافور',                  '5301'],
  ['Nordia',                   'نورديا',                     '5303'],
  ['Nehalim',                  'نهاليم',                     '5304'],
  ['Savion',                   'سافيون',                     '5293'],
  ['Sajur',                    'سجور',                       '5292'],
  ['Mitzpe Ramon',             'مزبي رامون',                 '5291'],
  ['Kafr Yasif',               'كفر ياسيف',                  '5276'],
  ['Kafr Kama',                'كفر كاما',                   '5294'],
  ['Kafr Habad',               'كفر هاباد',                  '5290'],
  ['Deir Hanna',               'دير حنا',                    '5275'],
  ['Matzkriyat Batya',         'مزكيريت باتيا',              '5278'],
  ['Hod Hasharon',             'هود هشارون',                 '5231'],
  ['Or Yehuda',                'أو يهودا',                   '5241'],
  ['Mevo Beitar',              'ميفو بيتار',                 '5243'],
  ['Nattif',                   'نتيفوت',                     '5247'],
  ['Afakeem',                  'افاقيم',                     '5248'],
  ['Nisher',                   'نيشر',                       '5250'],
  ['Et Tera',                  'إت تيرا',                    '5251'],
  ['Sderot',                   'سديروت',                     '5252'],
  ['Al-Khudayra',              'الخضيرة',                    '5220'],
  ['Giv\'at Ayim',             'جفع اتايم',                  '5227'],
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
  print('  Palestine Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kPalestineCities) {
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
  print('  Cities OK     : $ok / ${kPalestineCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
