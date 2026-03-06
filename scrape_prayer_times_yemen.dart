// Yemen Prayer Times Scraper — salatcalendar.com
//
// Switches cities using the official select_city/{id} endpoint, then fetches
// the full-year calendar via get_year.
//
// City IDs sourced from: salatcalendar.com/index.php/countries/cities/237
//
// Usage (no packages needed — pure dart:io):
//   dart scrape_prayer_times_yemen.dart
//
// Output:
//   assets/csv/yemen_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/yemen_prayer_times_2026.csv';
const int kCountryId = 237;

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Yemen Cities
//   [englishName, arabicName, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/237
// ---------------------------------------------------------------------------

const List<List<String>> kYemenCities = [
  // Major cities
  ['Sanaa',             'صنعاء',            '10421'],
  ['Aden',              'عدن',              '10424'],
  ['Taiz',              'تعز',              '10423'],
  ['Al Hudaydah',       'الحديدة',          '10422'],
  ['Al Mukalla',        'المكلا',           '10425'],
  ['Ibb',               'إب',               '10426'],
  ['Lahij',             'لحج',              '10435'],
  ['Zabid',             'زبيد',             '10428'],
  ['Bajil',             'باجيل',            '10429'],
  ['Bayt al-Faqih',     'بيت الفقيه',       '10432'],
  ['Yarim',             'يريم',             '10433'],
  ['Sahar',             'سحر',              '10434'],
  ['Siyan',             'سيان',             '10427'],
  ['Jowf al-Muqabah',   'جوف المقبة',       '10436'],
  ['Dhi as-Sufal',      'Dhi ك سوفال',      '10431'],

  // Additional cities
  ['Al-Bilili',         'البليلي',          '13297'],
  ['At-Tan\'us',        'التنعوس',          '13303'],
  ['Al-Jiraf',          'الجراف',           '13981'],
  ['Wahdat Abd al-Bari','وحدة عبد الباري',  '15256'],
  ['Taiz Alt',          'تعز',              '16412'],
  ['Al Jabin',          'Al Jabīn',         '18588'],
  ['Wadi al-Anab',      'وادي العنب',       '18279'],
  ['At-Tahalluf',       'التحالف',          '19386'],
  ['As-Sa\'id',         'الصعيد',           '19951'],
  ['Al-Husun',          'الحصون',           '19952'],
  ['Al-Mutaj\'arah',    'المتجعرة',         '19950'],
  ['Hisn al-Qa',        'Ḩişn al Qā\'',    '20329'],
  ['Al-Qalu\'ah',       'القلوعة',          '20117'],
  ['Wadi al-Hitab',     'وادي الحطاب',      '20116'],
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
  print('  Yemen Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kYemenCities) {
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
  print('  Cities OK     : $ok / ${kYemenCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
