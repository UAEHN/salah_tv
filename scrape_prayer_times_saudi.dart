/// Saudi Arabia Prayer Times Scraper — salatcalendar.com
///
/// Switches cities using the official select_city/{id} endpoint, then fetches
/// the full-year calendar via get_year.
///
/// City IDs sourced from: salatcalendar.com/index.php/countries/cities/187
///
/// Usage (no packages needed — pure dart:io):
///   dart scrape_prayer_times_saudi.dart
///
/// Output:
///   assets/csv/saudi_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/saudi_prayer_times_2026.csv';

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Saudi Arabia Cities
//   [englishName, arabicName, latitude, longitude, cityId]
//
// cityId — salatcalendar.com ID from /index.php/countries/cities/187
// ---------------------------------------------------------------------------

const List<List<String>> kSaudiCities = [
  // ── Major cities ──────────────────────────────────────────────────────────
  ['Riyadh',            'الرياض',          '24.7136', '46.6753', '20153'],
  ['Jeddah',            'جدة',             '21.5433', '39.1728', '10812'],
  ['Mecca',             'مكة المكرمة',      '21.3891', '39.8579', '12561'],
  ['Medina',            'المدينة المنورة',  '24.4686', '39.6142', '13975'],
  ['Dammam',            'الدمام',          '26.4207', '50.0888', '10813'],
  ['Tabuk',             'تبوك',            '28.3838', '36.5550', '15899'],
  ['Abha',              'أبها',            '18.2164', '42.5053', '10821'],
  ['Hail',              'حائل',            '27.5219', '41.6907', '10824'],
  ['Najran',            'نجران',           '17.4933', '44.1322', '10822'],
  ['Jizan',             'جازان',           '16.8892', '42.5511', '10819'],
  ['Al Qassim',         'القصيم',          '26.3267', '43.9717', '10816'],
  ['Yanbu',             'ينبع',            '24.0895', '38.0618', '16514'],
  ['Al Kharj',          'الخرج',           '24.1556', '47.3122', '10820'],
  ['Hafr Al Batin',     'حفر الباطن',      '28.4328', '45.9708', '10831'],
  ['Qatif',             'القطيف',          '26.5196', '50.0115', '10842'],
  ['Al Rass',           'الرس',            '25.8667', '43.5000', '10832'],
  // ── Medium cities ─────────────────────────────────────────────────────────
  ['Rabigh',            'رابغ',            '22.7994', '39.0345', '10848'],
  ['Afif',              'عفيف',            '23.9072', '42.9194', '10850'],
  ['Ad Dawadimi',       'الدوادمي',        '24.5067', '44.3948', '16662'],
  ['Bisha',             'بيشة',            '20.0000', '42.6000', '10840'],
  ['Samitah',           'صامطة',           '16.5833', '42.9333', '11297'],
  ['Tanumah',           'تنومة',           '19.1333', '42.1333', '11211'],
  ['Al Khafji',         'الخفجي',          '28.4167', '48.5000', '19507'],
  ['Thuwal',            'ثول',             '22.2833', '39.1000', '12501'],
  ['Rahimah',           'رحيمة',           '26.7000', '50.0667', '10853'],
  ['Al Badr',           'البدر',           '23.7833', '38.7833', '11313'],
  ['Safaniyah',         'السفانية',        '27.0167', '49.2333', '11303'],
  ['Al Ghat',           'الغاط',           '26.0333', '44.9500', '20298'],
  ['Yanbu Al Sinaiyah', 'ينبع الصناعية',   '24.0667', '38.1167', '11261'],
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
          referer: 'https://$kHost/index.php/countries/cities/187');
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
  print('  Saudi Arabia Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kSaudiCities) {
    final name       = city[0];
    final cityId     = city[4];
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
  print('  Cities OK     : $ok / ${kSaudiCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
