import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/remote_occasion_dto.dart';

/// Result of a successful fetch — the parsed entries plus the raw JSON
/// string and `etag` so the local cache can persist both verbatim.
class RemoteOccasionsPayload {
  final List<RemoteOccasionDto> occasions;
  final String rawJson;
  final String? etag;
  final int schemaVersion;

  const RemoteOccasionsPayload({
    required this.occasions,
    required this.rawJson,
    required this.etag,
    required this.schemaVersion,
  });
}

/// Downloads the occasions manifest from GitHub Pages. Bad entries are
/// silently skipped (forward-compat); transport failures throw
/// [ServerException] so the repository can map to a `NetworkFailure`.
class OccasionsRemoteDataSource {
  OccasionsRemoteDataSource({Dio? dio}) : _dio = dio ?? _buildDio();

  static const int _supportedSchemaVersion = 1;

  final Dio _dio;

  static Dio _buildDio() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

  Future<RemoteOccasionsPayload> fetch() async {
    try {
      final response = await _dio.get<String>(
        AppConfig.occasionsManifestUrl(),
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data ?? '';
      return _parse(body);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Occasions fetch failed');
    } catch (e) {
      throw ServerException('Occasions fetch error: $e');
    }
  }

  /// Parsing is exposed (package-private) so the local data source can
  /// reuse it when rehydrating cache / bundled asset.
  static RemoteOccasionsPayload parse(String body) => _parse(body);

  static RemoteOccasionsPayload _parse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw ServerException('Occasions manifest is not a JSON object');
    }
    final schemaVersion = (decoded['schema_version'] as num?)?.toInt() ?? 1;
    if (schemaVersion > _supportedSchemaVersion) {
      throw ServerException(
        'Occasions schema_version $schemaVersion not supported',
      );
    }
    final list = decoded['occasions'];
    final entries = <RemoteOccasionDto>[];
    if (list is List) {
      for (final raw in list) {
        final dto = RemoteOccasionDto.tryFromJson(raw);
        if (dto != null) entries.add(dto);
      }
    }
    return RemoteOccasionsPayload(
      occasions: entries,
      rawJson: body,
      etag: (decoded['etag'] as Object?)?.toString(),
      schemaVersion: schemaVersion,
    );
  }
}
