import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/quran_reciter.dart';
import '../domain/i_quran_api_repository.dart';

class QuranApiService implements IQuranApiRepository {
  static const _apiUrl = 'https://mp3quran.net/api/v3/reciters?language=ar';
  static const _cacheKey = 'quran_api_reciters_cache';
  static const _cacheTsKey = 'quran_api_reciters_ts';
  static const _cacheExpiryMs = 24 * 60 * 60 * 1000; // 24 hours

  /// Returns reciters from cache first, then fetches fresh data from API.
  /// Throws if no cache and network fails.
  @override
  Future<List<QuranApiReciter>> fetchReciters() async {
    // 1. Try loading from cache
    final cached = await _loadCache();
    if (cached != null) return cached;

    // 2. Fetch from API
    return _fetchFromApi();
  }

  /// Force refresh — ignores cache and fetches from API.
  @override
  Future<List<QuranApiReciter>> refreshReciters() => _fetchFromApi();

  // ── Private ─────────────────────────────────────────────────────────────

  Future<List<QuranApiReciter>?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cacheKey);
      final ts = prefs.getInt(_cacheTsKey) ?? 0;
      if (json == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > _cacheExpiryMs) return null; // expired

      final data = jsonDecode(json) as Map<String, dynamic>;
      return _parseReciters(data);
    } catch (_) {
      return null;
    }
  }

  Future<List<QuranApiReciter>> _fetchFromApi() async {
    final response = await http
        .get(Uri.parse(_apiUrl))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بالخادم (${response.statusCode})');
    }

    // Save to cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, response.body);
      await prefs.setInt(
          _cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw Exception('استجابة غير صالحة من الخادم');
    }
    return _parseReciters(data);
  }

  List<QuranApiReciter> _parseReciters(Map<String, dynamic> data) {
    final reciters = data['reciters'] as List? ?? [];
    final result = <QuranApiReciter>[];

    for (final r in reciters) {
      final moshafs = r['moshaf'] as List? ?? [];
      // Find a moshaf (reading) that covers all 114 surahs
      String? serverUrl;
      for (final m in moshafs) {
        if ((m['surah_total'] as int?) == 114) {
          serverUrl = m['server'] as String?;
          break;
        }
      }
      if (serverUrl == null || serverUrl.isEmpty) continue;

      result.add(QuranApiReciter(
        id: (r['id'] as num).toInt(),
        nameAr: r['name'] as String? ?? '',
        serverUrl: serverUrl,
      ));
    }

    return result;
  }
}
