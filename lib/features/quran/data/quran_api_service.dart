import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_config.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/quran_reciter.dart';
import '../domain/i_quran_api_repository.dart';

class QuranApiService implements IQuranApiRepository {
  final Dio _dio;

  QuranApiService(this._dio);

  static const _cacheExpiryMs = 24 * 60 * 60 * 1000; // 24 hours

  static String _cacheKey(String language) => 'quran_api_reciters_cache_$language';
  static String _cacheTsKey(String language) => 'quran_api_reciters_ts_$language';

  /// Returns reciters from cache first, then fetches fresh data from API.
  @override
  Future<Either<Failure, List<QuranApiReciter>>> fetchReciters({String language = 'ar'}) async {
    final cached = await _loadCache(language);
    if (cached != null) return Right(cached);
    return _fetchFromApi(language);
  }

  /// Force refresh: ignores cache and fetches from API.
  @override
  Future<Either<Failure, List<QuranApiReciter>>> refreshReciters({String language = 'ar'}) =>
      _fetchFromApi(language);

  Future<List<QuranApiReciter>?> _loadCache(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cacheKey(language));
      final ts = prefs.getInt(_cacheTsKey(language)) ?? 0;
      if (json == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > _cacheExpiryMs) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return _parseReciters(data);
    } catch (e) {
      debugPrint('[QuranApi] cache load failed: $e');
      return null;
    }
  }

  Future<Either<Failure, List<QuranApiReciter>>> _fetchFromApi(String language) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.quranReciterApiUrl(language: language),
        options: Options(receiveTimeout: const Duration(seconds: 20)),
      );

      if (response.statusCode != 200 || response.data == null) {
        return Left(
          ServerFailure('Server request failed (${response.statusCode})'),
        );
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey(language), jsonEncode(response.data));
        await prefs.setInt(_cacheTsKey(language), DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        debugPrint('[QuranApi] cache write failed: $e');
      }

      try {
        return Right(_parseReciters(response.data!));
      } on FormatException {
        return const Left(ServerFailure('Invalid server response'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: $e'));
    } catch (e) {
      return Left(ServerFailure('Network error: $e'));
    }
  }

  List<QuranApiReciter> _parseReciters(Map<String, dynamic> data) {
    final reciters = data['reciters'] as List? ?? [];
    final result = <QuranApiReciter>[];

    for (final r in reciters) {
      final moshafs = r['moshaf'] as List? ?? [];
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
