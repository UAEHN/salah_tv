// Iraq Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/102
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_iraq.dart
//
// Output:
//   assets/csv/iraq_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/iraq_prayer_times_2026.csv';
const int kCountryId = 102;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Iraq Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/102
// ---------------------------------------------------------------------------

const List<List<String>> kIraqCities = [
  // Major cities
  ['Baghdad',              'بغداد',              '5043'],
  ['Mosul',                'الموصل',             '5047'],
  ['New Mosul',            'الموصل الجديدة',     '5045'],
  ['Basra',                'البصرة',             '5044'],
  ['Old Basra',            'البصرة القديمة',     '5046'],
  ['Erbil',                'اربيل',              '5048'],
  ['Kirkuk',               'كركوك',              '5051'],
  ['Najaf',                'النجف',              '5052'],
  ['Al-Nasiriyah',         'الناصرية',           '5053'],
  ['Al-Amara',             'العمارة',            '5054'],
  ['Al-Diwaniyah',         'الديوانية',          '5055'],
  ['Al-Kut',               'الكوت',              '5056'],
  ['Al-Hillah',            'الحلة',              '5057'],
  ['Al-Ramadi',            'الرمادي',            '5058'],
  ['Al-Fallujah',          'الفلوجة',            '5059'],
  ['Al-Samawah',           'السماوة',            '5060'],
  ['Baqubah',              'بعقوبة',             '5061'],
  ['Sina',                 'سينا',               '5062'],
  ['Al-Zubayr',            'الزبير',             '5063'],
  ['Al-Faw',               'الفاو',              '5064'],
  ['Zakho',                'زاخو',               '5065'],
  ['Al-Hartha',            'الحارثة',            '5066'],
  ['Al-Shatrah',           'الشطرة',             '5067'],
  ['Al-Hai',               'الحي',               '5068'],
  ['Shamshemal',           'شمشمال',             '5069'],
  ['Al-Khalis',            'الخالص',             '5070'],
  ['Tuz Khurmatu',         'توزخورماتو',         '5071'],
  ['Al Al-Hindiyah',       'ال الهندية',         '5073'],
  ['Al-Muqdadiyah',        'المقدادية',          '5075'],
  ['Al-Rumaytha',          'الرميثة',            '5076'],
  ['Koi Sanjaq',           'كوي سانجاك',         '5077'],
  ['Al-Aziziyah',          'العزيزية',           '5078'],
  ['Al-Musayab',           'المسيب',             '5079'],
  ['Tikrit',               'تكريت',              '5080'],
  ['Balad',                'بلد',                '5082'],
  ['Sinjar',               'سنجار',              '5083'],
  ['Beiji',                'بيجي',               '5085'],
  ['Al-Majjar Al-Kabir',   'المجار الكبير',      '5086'],
  ['Dhorb Al',             'ضرب ال',             '5087'],
  ['Hadithah',             'حديثة',              '5088'],
  ['Ghamas',               'غماس',               '5089'],
  ['Sadat Al-Hindiyah',    'سادات الهندية',      '5090'],
  ['Kafri',                'كفري',               '5091'],
  ['Mandali',              'مندلي',              '5092'],
  ['Qara Qosh',            'قرة قوش',            '5093'],
  ['Benjwin',              'بنجوين',             '5094'],
  ['Al-Dujayl',            'الدجيل',             '5095'],
  ['Tel Kaif',             'تل كايف',            '5096'],
  ['Al-Mishkhab',          'المشخاب',            '5097'],
  ['Ruwanduz',             'رواندوز',            '5098'],
  ['Al-Shinafiyah',        'الشنيفية',           '5099'],
  ['Al-Rutbah',            'الرطبة',             '5100'],
  ['Afaq',                 'آفاق',               '5101'],
  ['Nahdat Al-Fuhud',      'نهضة الفهود',        '5102'],
  ['Rawa',                 'راوة',               '5103'],
  ['Anah',                 'أناه',               '5104'],
  ['Ali Al-Gharbi',        'علي الغربي',         '5105'],
  ['Abu Ghraib',           'ابو غريب',           '5049'],

  // Additional cities
  ['Irbil',                'إربل',               '13619'],
  ['Tal Afar',             'تلعفر',              '13724'],
  ['Daquq',                'داقوق',              '13781'],
  ['Al-Hamdaniyah District','قضاء الحمدانية',    '13750'],
  ['Al-Huwija',            'الحويجة',            '13671'],
  ['Al-Madinah',           'المدينة',            '13443'],
  ['Karbala',              'كربلاء',             '18056'],
  ['Sulaymaniyah',         'السليمانية',         '19821'],
  ['Dohuk',                'دَهُکْ',             '19936'],
  ['Khanaqin',             'خانقين',             '20057'],
  ['Al-Qa\'im',            'القائم',             '19559'],
  ['Souq Al-Shuyukh',      'سوق الشيوخ',         '19334'],
  ['Al-Mahmudiyah',        'المحمودية',          '16062'],
  ['Al-Rashid',            'الرشيد',             '16423'],
  ['Al-Kahlaa',            'الكحلاء',            '20192'],
  ['Al-Muthanna',          'المثنى',             '16489'],
  ['Al-Mansuriyah',        'المنصورية',          '19524'],
  ['Al-Nasiriyah Alt',     'الناصرية',           '10874'],
  ['Al-Amara Alt',         'العمارة',            '14350'],
  ['Al-Ramadi Alt',        'الرمادي',            '11125'],
  ['Basra Alt',            'البصرة',             '15908'],
  ['Al-Intisar',           'الانتصار',           '15300'],
  ['Al-Izdihaar 1',        'الازدهار ١',         '17404'],
  ['Al-Darwaza',           'الدرويزه',           '16116'],
  ['Al-Tuwaysah',          'الطويسة',            '16153'],
  ['Al-Salihiyah',         'الصالحية',           '19516'],
  ['Al-Wahda',             'الوحدة',             '18654'],
  ['Al-Muallimin',         'المعلمين',           '16759'],
  ['Badran',               'بدران',              '15020'],
  ['Bilduz',               'بلدروز',             '15599'],
  ['Abitirah',             'ابتيرة',             '15600'],
  ['Burushki',             'بروشكي',             '15932'],
  ['Binyawin',             'بينجوين',            '16737'],
  ['Rania',                'رانية',              '16156'],
  ['Semile',               'سميل',               '18387'],
  ['Aqrah',                'عقرة',               '17905'],
  ['Qassawi',              'قصاوي',              '16075'],
  ['Kari Bahin',           'كاري بهين',          '18685'],
  ['Kasnazan',             'كسنزان',             '15906'],
  ['Mashirja',             'مشيرجه',             '19307'],
  ['Jomaan',               'جومان',              '19840'],
  ['Abu Rummanah',         'ابو رمانة',          '19492'],
  ['Al-Amgassis',          'الأمگاصيص',          '19051'],
  ['Hamdan',               'Ḩamdān',             '10875'],
  ['Muhammad Al-Hasan',    'Muḩammad al Ḩasan',  '16256'],
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
  print('  Iraq Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kIraqCities) {
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
  print('  Cities OK     : $ok / ${kIraqCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
