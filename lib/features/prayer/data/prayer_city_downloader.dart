import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/app_config.dart';
import '../../../core/error/failures.dart';
import '../../analytics/domain/i_analytics_service.dart';
import '../domain/cancellation_token.dart';
import '../domain/i_prayer_city_downloader.dart';
import 'prayer_city_json_parser.dart';

class PrayerCityDownloader implements IPrayerCityDownloader {
  PrayerCityDownloader({IAnalyticsService? analytics})
    : _analytics = analytics,
      _dio = _buildDio();

  final Dio _dio;
  final IAnalyticsService? _analytics;

  static Dio _buildDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  Future<Either<Failure, ({String hash, List<List<int>> rows})>> fetchCity(
    String country,
    String citySlug,
    CancellationToken cancelToken,
  ) async {
    final dioToken = CancelToken();
    try {
      final url = AppConfig.prayerCityUrl(country, citySlug);
      final response = await _dio.get<String>(
        url,
        cancelToken: dioToken,
        options: Options(responseType: ResponseType.plain),
      );

      if (cancelToken.isCancelled) {
        return const Left(CancelledFailure());
      }

      final contentType = response.headers.value('content-type') ?? '';
      if (contentType.isNotEmpty && !contentType.contains('json')) {
        _logNetFail('fetchCity', response.statusCode ?? 0, 'bad_content_type');
        return const Left(NetworkFailure('Unexpected content type'));
      }

      final body = response.data ?? '';
      final payload = await compute(parseCityJson, body);
      return Right(payload);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || cancelToken.isCancelled) {
        return const Left(CancelledFailure());
      }
      _logNetFail('fetchCity', e.response?.statusCode ?? 0, e.type.name);
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } on FormatException catch (e) {
      _logNetFail('fetchCity', 0, 'format_exception');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      _logNetFail('fetchCity', 0, 'unknown');
      return Left(NetworkFailure('$e'));
    }
  }

  @override
  Future<Map<String, String>?> fetchManifest() async {
    try {
      final url = AppConfig.prayerManifestUrl();
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final data = response.data;
      if (data == null) return null;
      final cities = data['cities'] as Map<String, dynamic>?;
      return cities?.map((k, v) => MapEntry(k, v as String));
    } catch (e) {
      final code = e is DioException ? (e.response?.statusCode ?? 0) : 0;
      final type = e is DioException ? e.type.name : 'unknown';
      _logNetFail('fetchManifest', code, type);
      return null;
    }
  }

  void _logNetFail(String repo, int code, String errorType) => _analytics
      ?.logNetworkFailure(repo: repo, statusCode: code, errorType: errorType);
}
