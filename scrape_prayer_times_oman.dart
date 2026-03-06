/// Oman Prayer Times Scraper — salatcalendar.com
///
/// Switches cities using the official select_city/{id} endpoint, then fetches
/// the full-year calendar via get_year.
///
/// City IDs sourced from: salatcalendar.com/index.php/countries/cities/161
///
/// Usage (no packages needed — pure dart:io):
///   dart scrape_prayer_times_oman.dart
///
/// Output:
///   assets/csv/oman_prayer_times_2026.csv

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const String kHost = 'www.salatcalendar.com';
const String kSeedDay = '01/01/2026';
const String kOutputFile = 'assets/csv/oman_prayer_times_2026.csv';

const Duration kRequestDelay = Duration(seconds: 2);
const Duration kCityDelay = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Oman Cities
//   [englishName, arabicName, latitude, longitude, cityId, fallbackCityId]
//
// cityId       — salatcalendar.com ID from /index.php/countries/cities/161
//                '' means the city is not in their database
// fallbackCityId — used only when cityId=='' (nearest city that has year data)
// ---------------------------------------------------------------------------

const List<List<String>> kOmanCities = [
  // ── Major cities (all have year data on salatcalendar.com) ────────────────
  ['Muscat',           'مسقط',          '23.5880', '58.3829', '7431'],
  ['Salalah',          'صلالة',         '17.0151', '54.0924', '7433'],
  ['Sohar',            'صحار',          '24.3615', '56.7351', '7435'],
  ['Nizwa',            'نزوى',          '22.9333', '57.5333', '7441'],
  ['Ibri',             'عبري',          '23.2255', '56.5161', '7437'],
  ['Al Buraimi',       'البريمي',       '24.2500', '55.7833', '7440'],
  ['Al Rustaq',        'الرستاق',       '23.3907', '57.4245', '7439'],
  ['Ibra',             'إبراء',         '22.6907', '58.5339', '7446'],
  ['Al Seeb',          'السيب',         '23.6700', '58.1794', '13277'],
  ['Bousher',          'بوشر',          '23.5500', '58.4000', '7434'],
  ['Al Suwaiq',        'السويق',        '23.8500', '57.4333', '7436'],
  ['Al Khabourah',     'الخابورة',      '23.9667', '57.0833', '7443'],
  ['Shinas',           'شناص',          '24.7500', '56.4667', '7444'],
  ['Sahm',             'صحم',           '24.1667', '56.8833', '7438'],
  ['Izki',             'ازكي',          '22.9333', '57.7667', '7445'],
  ['Adam',             'آدم',           '22.3833', '57.5333', '7450'],
  ['Sinaw',            'سناو',          '22.4333', '58.0000', '16909'],
  ['Khasab',           'خصب',           '26.1797', '56.2477', '20046'],
  ['Badbd',            'بدبد',          '23.4092', '57.8914', '7447'],
  ['Al Qabil',         'القابل',        '22.6500', '58.3667', '7452'],
  ['Bayt Al Awabi',    'بيت العوابي',    '23.3000', '57.5333', '7453'],
  ['Yanqul',           'ينقل',          '23.5833', '56.1000', '7451'],
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

  /// Load the homepage to get a valid ci_session cookie.
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

  /// GET select_city/{id} WITHOUT following the redirect so we capture the
  /// Set-Cookie header on the 302 response (where the city switch is stored).
  Future<bool> selectCity(String cityId) async {
    try {
      final req = await _client.getUrl(
          Uri.https(kHost, '/index.php/countries/select_city/$cityId'));
      req.followRedirects = false; // must NOT follow — cookie is on the 302
      _applyHeaders(req,
          referer: 'https://$kHost/index.php/countries/cities/161');
      final res = await req.close();
      _storeCookies(res); // capture city cookie from the 302
      await res.drain<void>();
      // 307/302 = city switched (redirect to home); 200 = rendered inline
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
  print('  Oman Prayer Times Scraper — 2026');
  print('  Source: salatcalendar.com');
  print('====================================================\n');

  final csv = <String>['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  int ok = 0, failed = 0;

  for (final city in kOmanCities) {
    final name       = city[0];
    final cityId     = city[4];               // '' if not in salatcalendar DB
    final fbCityId   = city.length > 5 ? city[5] : null; // fallback city ID
    print('--- $name ---');

    final session = HttpSession();
    try {
      if (!await session.init()) {
        print('  SKIP: session init failed\n');
        failed++;
        continue;
      }
      await Future.delayed(kRequestDelay);

      // ── Switch to this city ──────────────────────────────────────────────
      final targetId = cityId.isNotEmpty ? cityId : fbCityId;
      if (targetId == null) {
        print('  SKIP: no city ID and no fallback\n');
        failed++;
        continue;
      }

      final switched = await session.selectCity(targetId);
      print('  selectCity($targetId): ${switched ? "OK" : "failed"}');
      if (!switched) {
        print('  SKIP: could not switch city\n');
        failed++;
        continue;
      }
      await Future.delayed(kRequestDelay);

      // ── Fetch the year calendar ──────────────────────────────────────────
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
  print('  Cities OK     : $ok / ${kOmanCities.length}');
  print('  Cities failed : $failed');
  print('  Total rows    : ${csv.length - 1}');
  print('  Output        : ${outFile.absolute.path}');
  print('====================================================');
}
