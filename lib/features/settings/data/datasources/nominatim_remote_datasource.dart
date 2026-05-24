import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/nominatim_place_model.dart';
import '../nominatim_throttler.dart';

/// HTTP datasource hitting Nominatim's `/search` endpoint.
///
/// Sends the required `User-Agent` + `Referer` headers and serializes
/// requests through [NominatimThrottler] so we stay within the public
/// instance's 1 req/sec policy.
class NominatimRemoteDataSource {
  final Dio _dio;
  final NominatimThrottler _throttler;

  const NominatimRemoteDataSource(this._dio, this._throttler);

  Future<List<NominatimPlaceModel>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    await _throttler.acquire();
    if (cancelToken?.isCancelled ?? false) {
      throw DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: ''),
      );
    }
    try {
      final url = AppConfig.nominatimSearchUrl(query: query);
      final response = await _dio.getUri<dynamic>(
        Uri.parse(url),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'User-Agent': AppConfig.nominatimUserAgent,
            'Accept-Language': 'ar,en',
            'Referer': AppConfig.privacyPolicyUrl,
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final raw = response.data;
      if (raw is! List) {
        throw const ServerException('Unexpected Nominatim payload');
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map(NominatimPlaceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      if (e.error is SocketException) {
        throw ServerException('Nominatim offline: ${e.message ?? ''}');
      }
      throw ServerException(e.message ?? 'Nominatim request failed');
    }
  }
}
