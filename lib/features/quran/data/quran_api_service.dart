import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_config.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/quran_reciter.dart';
import '../domain/i_quran_api_repository.dart';

class QuranApiService implements IQuranApiRepository {
  final Dio _dio;

  QuranApiService(this._dio);

  static const _cacheKey = 'quran_api_reciters_cache';
  static const _cacheTsKey = 'quran_api_reciters_ts';
  static const _cacheExpiryMs = 24 * 60 * 60 * 1000; // 24 hours

  /// Returns reciters from cache first, then fetches fresh data from API.
  @override
  Future<Either<Failure, List<QuranApiReciter>>> fetchReciters() async {
    final cached = await _loadCache();
    if (cached != null) return Right(cached);
    return _fetchFromApi();
  }

  /// Force refresh — ignores cache and fetches from API.
  @override
  Future<Either<Failure, List<QuranApiReciter>>> refreshReciters() =>
      _fetchFromApi();

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

  Future<Either<Failure, List<QuranApiReciter>>> _fetchFromApi() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.quranReciterApiUrl,
        options: Options(receiveTimeout: const Duration(seconds: 20)),
      );

      if (response.statusCode != 200 || response.data == null) {
        return Left(
          ServerFailure('فشل الاتصال بالخادم (${response.statusCode})'),
        );
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(response.data));
        await prefs.setInt(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
      } catch (_) {}

      try {
        return Right(_parseReciters(response.data!));
      } on FormatException {
        return const Left(ServerFailure('استجابة غير صالحة من الخادم'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('خطأ في الاتصال: $e'));
    } catch (e) {
      return Left(ServerFailure('خطأ في الاتصال: $e'));
    }
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

      result.add(
        QuranApiReciter(
          id: (r['id'] as num).toInt(),
          nameAr: r['name'] as String? ?? '',
          serverUrl: serverUrl,
        ),
      );
    }

    return result;
  }
}
