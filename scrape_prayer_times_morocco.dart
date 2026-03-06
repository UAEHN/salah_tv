// Morocco Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/144
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_morocco.dart
//
// Output:
//   assets/csv/morocco_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/morocco_prayer_times_2026.csv';
const int kCountryId = 144;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Morocco Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/144
// ---------------------------------------------------------------------------

const List<List<String>> kMoroccoCities = [
  // Major cities
  ['Casablanca',       'الدار البيضاء',  '6885'],
  ['Rabat',            'الرباط',         '6886'],
  ['Fez',              'فاس',            '6887'],
  ['Marrakesh',        'مراكش',          '6888'],
  ['Agadir',           'أغادير',         '6889'],
  ['Tangier',          'طنجة',           '6890'],
  ['Meknes',           'مكناس',          '6891'],
  ['Kenitra',          'القنيطرة',       '6893'],
  ['Tetouan',          'تطوان',          '6894'],
  ['Safi',             'صافي',           '6895'],
  ['Khouribga',        'خريبكة',         '6896'],
  ['Beni Mellal',      'بني ملال',       '6897'],
  ['Taza',             'تازة',           '6899'],
  ['Settat',           'سطات',           '6901'],
  ['Larache',          'العرائش',        '6902'],
  ['Ksar El Kebir',    'قصر الكبير',     '6903'],
  ['Khémisset',        'الخميسات',       '6904'],
  ['Guelmim',          'كلميم',          '6905'],
  ['Berrechid',        'برشيد',          '6906'],
  ['Wadi Zem',         'وادي زم',        '6907'],
  ['Sidi Kacem',       'الفقيه بن صلاح', '6908'],
  ['Taourirt',         'تاوريرت',        '6909'],
  ['Khenifra',         'خنيفرة',         '6913'],
  ['Essaouira',        'الصويرة',        '6915'],
  ['Tiflet',           'تيفلت',          '6916'],
  ['Oulad Teima',      'أولاد تيما',     '6917'],
  ['Sefrou',           'صفرو',           '6918'],
  ['Youssoufia',       'اليوسفية',       '6919'],
  ['Tan-Tan',          'طانطان',         '6920'],
  ['Ouezzane',         'وزان',           '6921'],
  ['Jerrada',          'جرسيف',          '6922'],
  ['Ouarzazate',       'ورزازات',        '6923'],
  ['Trahanimine',      'تراهانيماين',    '6924'],
  ['Tiznit',           'تزنيت',          '6925'],
  ['Kasbahs',          'محمد بوليش',     '6926'],
  ['Azrou',            'أزرو',           '6927'],
  ['Midelt',           'ميدلت',          '6928'],
  ['Sale',             'الصخيرات',       '6929'],
  ['Girarda',          'جيرادا',         '6930'],
  ['Tadla',            'قصبة تادلة',     '6931'],
  ['Sidi Bennour',     'سيدي بنور',      '6932'],
  ['Martil',           'مرتيل',          '6933'],
  ['El Aioun',         'العيون',         '6937'],
  ['Zagora',           'زاغورة',         '6938'],
  ['Taounate',         'تاونات',         '6939'],
  ['Sidi Yahya',       'سيدى يحيى الغرب','6940'],
  ['Tissemsilt',       'تسايو',          '6941'],
  ['Assilah',          'أصيلة',          '6942'],
  ['El Hajeb',         'الحاجب',         '6943'],
  ['Bcharre',          'بشرى بلقسيري',   '6944'],
  ['Bouznique',        'بوزنيقة',        '6945'],
  ['Amezrou',          'امزوريين',       '6946'],
  ['Tahala',           'تاهالا',         '6947'],
  ['Sidi Ifni',        'سيدي افني',      '6948'],
  ['Ahfir',            'احفير',          '6949'],
  ['Ifrane',           'إفران',          '6950'],
  ['Figuig',           'فيجويج',         '6951'],
  ['Tafraoute',        'تفراوت',         '6952'],
  ['Sidi Smaiil',      'سيدي سمايل',     '6953'],
  ['Jebel Teskaouin',  'جبل تسكاوين',   '6954'],
  ['Sidi Slimane',     'سيدي سليمان',    '6911'],
  ['Sidi Kacem',       'سيدي قاسم',      '6912'],
  ['Chefchaouen',      'شفشاون',         '6936'],
  ['Tinghir',          'تنغير',          '6935'],
  ['Taroudannt',       'تارودانت',       '6914'],

  // Additional cities
  ['Oujda',            'وجدة',           '11450'],
  ['Al Hoceima',       'الحسيمة',        '11002'],
  ['Dakhla',           'العيون',         '10694'],
  ['El Jadida',        'الجديدة',        '16710'],
  ['Nador',            'الناظور',        '17909'],
  ['Marrakech',        'مراكش',          '13243'],
  ['Agdal',            'Agdal',          '18293'],
  ['Ain Taoujdat',     'Aïn Taoujdat',   '18774'],
  ['Al Fqih Ben Calah','Al Fqih Ben Çalah','18883'],
  ['Azemmour',         'Azemmour',       '20052'],
  ['Hay El Ouidadiya', 'Hay El Ouidadiya','14338'],
  ['Hay Ettinis',      'Hay Ettinis',    '16203'],
  ['Hivernage',        'Hivernage',      '13015'],
  ['Iheddadene',       'Iheddadene',     '17634'],
  ['Moulay Bousselham','Moulay Bousselham','15255'],
  ['Sidi Marouf',      'Sidi Ma\'rouf',  '18532'],
  ['Tahla',            'Tahla',          '12567'],
  ['Haraouin',         'الهراويين',      '18956'],
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
  print('  Morocco Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kMoroccoCities) {
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
  print('  Cities OK     : $ok / ${kMoroccoCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
