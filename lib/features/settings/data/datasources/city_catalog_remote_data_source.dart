import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/remote_city_catalog.dart';

/// Result of a successful fetch — the parsed catalog plus the raw JSON string
/// so the local cache can persist it verbatim for next launch.
typedef CityCatalogPayload = ({RemoteCityCatalog catalog, String rawJson});

/// Downloads the remote city catalog (`prayer_data/catalog.json`) from GitHub
/// Pages. Bad entries are silently skipped (forward-compat); transport or
/// schema failures throw [ServerException] so the repository maps them to a
/// silent fallback (cache → bundled assets).
class CityCatalogRemoteDataSource {
  CityCatalogRemoteDataSource({Dio? dio}) : _dio = dio ?? _buildDio();

  static const int _supportedSchemaVersion = 1;

  final Dio _dio;

  static Dio _buildDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  Future<CityCatalogPayload> fetch() async {
    try {
      final response = await _dio.get<String>(
        AppConfig.prayerCatalogUrl(),
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data ?? '';
      return (catalog: _parse(body), rawJson: body);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'City catalog fetch failed');
    } catch (e) {
      throw ServerException('City catalog fetch error: $e');
    }
  }

  /// Exposed so the local data source can rehydrate a cached raw string.
  static RemoteCityCatalog parse(String body) => _parse(body);

  static RemoteCityCatalog _parse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw ServerException('City catalog is not a JSON object');
    }
    final version = (decoded['v'] as num?)?.toInt() ?? 1;
    if (version > _supportedSchemaVersion) {
      throw ServerException('City catalog v$version not supported');
    }

    final countries = <RemoteCatalogCountry>[];
    final raw = decoded['countries'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is! Map) return;
        countries.add(
          RemoteCatalogCountry(
            key: key.toString().toLowerCase(),
            arabicName: (value['ar'] as String?) ?? key.toString(),
            englishName: (value['en'] as String?) ?? key.toString(),
            cities: _parseCities(value['cities']),
          ),
        );
      });
    }
    return RemoteCityCatalog(version: version, countries: countries);
  }

  static List<RemoteCatalogCity> _parseCities(Object? raw) {
    final cities = <RemoteCatalogCity>[];
    if (raw is! List) return cities;
    for (final entry in raw) {
      if (entry is! Map) continue;
      final en = entry['en'] as String?;
      if (en == null || en.isEmpty) continue;
      final ar = entry['ar'] as String?;
      cities.add(
        RemoteCatalogCity(
          englishName: en,
          arabicName: (ar != null && ar.isNotEmpty) ? ar : en,
        ),
      );
    }
    return cities;
  }
}
