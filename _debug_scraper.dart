import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  final cookies = <String, String>{};

  void storeCookies(HttpClientResponse res) {
    for (final c in res.cookies) {
      cookies[c.name] = c.value;
    }
  }

  String cookieHeader() =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void applyHeaders(HttpClientRequest req,
      {String? referer, bool xhr = false}) {
    final h = cookieHeader();
    if (h.isNotEmpty) req.headers.set('Cookie', h);
    req.headers
      ..set('User-Agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..set('Accept', '*/*')
      ..set('Accept-Language', 'ar,en-US;q=0.7,en;q=0.3');
    if (referer != null) req.headers.set('Referer', referer);
    if (xhr) req.headers.set('X-Requested-With', 'XMLHttpRequest');
  }

  Future<(int, String)> postRaw(String path, String body,
      {bool xhr = true}) async {
    final bytes = utf8.encode(body);
    final req =
        await client.postUrl(Uri.https('www.salatcalendar.com', path));
    req.followRedirects = true;
    applyHeaders(req,
        referer: 'https://www.salatcalendar.com/', xhr: xhr);
    req.headers
      ..set('Content-Type', 'application/x-www-form-urlencoded')
      ..contentLength = bytes.length;
    req.add(bytes);
    final res = await req.close();
    storeCookies(res);
    return (res.statusCode, await res.transform(utf8.decoder).join());
  }

  // 1. Init session
  var req = await client.getUrl(Uri.https('www.salatcalendar.com', '/'));
  req.followRedirects = true;
  applyHeaders(req);
  var res = await req.close();
  storeCookies(res);
  await res.drain<void>();
  print('Init city: ${_city(cookies['user_location'])}');

  await Future.delayed(const Duration(milliseconds: 800));

  // 2. set_location with PHP-style nested geoData (jQuery serialization format)
  //    geoData[geonames][0][toponymName]=Dubai&geoData[geonames][0][lat]=...
  final geoFields = {
    'userLat': '25.2048',
    'userLng': '55.2708',
    // PHP-style nested (jQuery serializes JS objects this way)
    'geoData[geonames][0][toponymName]': 'Dubai',
    'geoData[geonames][0][name]': 'Dubai',
    'geoData[geonames][0][lat]': '25.2048',
    'geoData[geonames][0][lng]': '55.2708',
    'geoData[geonames][0][countryCode]': 'AE',
    'geoData[geonames][0][countryName]': 'United Arab Emirates',
    'geoData[geonames][0][countryId]': '784',
    'geoData[geonames][0][geonameId]': '292223',
    'geoData[geonames][0][adminCode1]': '07',
    'geoData[geonames][0][adminName1]': 'Dubai',
    'geoData[geonames][0][fcode]': 'PPLA',
    'geoData[geonames][0][fcl]': 'P',
    'geoData[geonames][0][population]': '3478300',
  };
  final body = geoFields.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');

  print('\n--- set_location (Dubai, PHP-style geoData) ---');
  final (code, resp) =
      await postRaw('/index.php/app/set_location', body);
  print('Status: $code');
  print('Response: $resp');
  print('City after: ${_city(cookies['user_location'])}');

  await Future.delayed(const Duration(milliseconds: 800));

  // 3. get_year
  if (_city(cookies['user_location']).contains('Dubai') ||
      _city(cookies['user_location']).contains('دبي')) {
    print('\n--- get_year (should now be Dubai) ---');
    final (yCode, yBody) = await postRaw(
        '/index.php/app/get_year', 'day=01%2F01%2F2026');
    print('Status: $yCode');
    try {
      final html = (jsonDecode(yBody) as Map)['html'] as String;
      // Find a date and the 6 prayer times after it
      final dateMatch = RegExp(r'\d{2}/\d{2}/\d{4}').firstMatch(html);
      if (dateMatch != null) {
        final after = html.substring(dateMatch.end);
        final times =
            RegExp(r'\d{2}:\d{2}').allMatches(after).take(6).map((m) => m.group(0)).toList();
        print('Date: ${dateMatch.group(0)} → ${times.join(', ')}');
      }
    } catch (_) {
      print('Body: ${yBody.substring(0, yBody.length.clamp(0, 200))}');
    }
  }

  client.close(force: true);
}

String _city(String? encoded) {
  if (encoded == null || encoded.isEmpty) return '(empty)';
  try {
    final map =
        jsonDecode(Uri.decodeComponent(encoded)) as Map<String, dynamic>;
    return '${map['City']} (${map['Latitude']}, ${map['Longitude']})';
  } catch (_) {
    return '(parse error)';
  }
}
