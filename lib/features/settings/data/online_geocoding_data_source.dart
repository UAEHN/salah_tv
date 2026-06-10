import 'package:dio/dio.dart';

import '../../../core/app_config.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/online_geocoding_result.dart';

/// Thin wrapper around the Nominatim search API. Returns parsed results or
/// throws [ServerException] / [NetworkException] — repository layer maps
/// these to `Either<Failure, _>`.
class OnlineGeocodingDataSource {
  OnlineGeocodingDataSource({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static final _arabicScript = RegExp(r'[؀-ۿ]');

  static Dio _buildDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        // Nominatim policy: stable, app-specific UA + contact email.
        'User-Agent': AppConfig.nominatimUserAgent,
        'Accept': 'application/json',
      },
    ),
  );

  /// Match result language to the script the user typed. Arabic query → ar,en;
  /// Latin query → en,ar. Avoids the "I typed Khor Fakkan and got خور فكان"
  /// confusion.
  String _languagePriorityFor(String query) =>
      _arabicScript.hasMatch(query) ? 'ar,en' : 'en,ar';

  /// Reverse geocode (lat/lng → place). Uses the same Nominatim backend as
  /// [search] so GPS auto-detect produces identical results to manual search
  /// for the same location — solves "GPS shows Unknown for small towns the
  /// native Android/Google geocoder doesn't recognize".
  ///
  /// [localeHint] controls the response language (e.g. "ar" or "en"). Falls
  /// back to "ar,en" so Arabic users see Arabic names by default.
  Future<OnlineGeocodingResult?> reverse({
    required double latitude,
    required double longitude,
    String? localeHint,
  }) async {
    try {
      final lang = (localeHint == 'en') ? 'en,ar' : 'ar,en';
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.nominatimReverseUrl,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'json',
          'addressdetails': 1,
          'accept-language': lang,
          'zoom': 14, // city/town level — avoids returning a single building
        },
        options: Options(headers: {'Accept-Language': lang}),
      );
      final data = response.data;
      if (data == null) return null;
      return _parseResult(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Nominatim reverse request failed');
    } on FormatException catch (e) {
      throw ServerException('Bad Nominatim reverse payload: ${e.message}');
    }
  }

  Future<List<OnlineGeocodingResult>> search(
    String query, {
    String? countryCode,
  }) async {
    try {
      final iso = countryCode?.trim().toLowerCase();
      final lang = _languagePriorityFor(query);
      final response = await _dio.get<List<dynamic>>(
        AppConfig.nominatimSearchUrl,
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 10,
          'addressdetails': 1,
          'accept-language': lang,
          if (iso != null && iso.isNotEmpty) 'countrycodes': iso,
        },
        options: Options(headers: {'Accept-Language': lang}),
      );
      final data = response.data;
      if (data == null) return const [];
      final parsed = data
          .whereType<Map<String, dynamic>>()
          .map(_parseResult)
          .whereType<OnlineGeocodingResult>();
      return _dedupeByNameAndCountry(parsed);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Nominatim request failed');
    } on FormatException catch (e) {
      throw ServerException('Bad Nominatim payload: ${e.message}');
    }
  }

  /// Nominatim returns multiple OSM entries per place (city, admin boundary,
  /// node, port…) which look identical in the UI. Keep the first occurrence
  /// per (lowercased name, ISO country) so the list stays uncluttered.
  List<OnlineGeocodingResult> _dedupeByNameAndCountry(
    Iterable<OnlineGeocodingResult> results,
  ) {
    final seen = <String>{};
    final unique = <OnlineGeocodingResult>[];
    for (final r in results) {
      final key = '${r.name.trim().toLowerCase()}|${r.countryCode}';
      if (seen.add(key)) unique.add(r);
    }
    return List.unmodifiable(unique);
  }

  OnlineGeocodingResult? _parseResult(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['lat']}');
    final lon = double.tryParse('${json['lon']}');
    if (lat == null || lon == null) return null;

    final address = json['address'] as Map<String, dynamic>?;
    final name =
        (address?['city'] ??
                address?['town'] ??
                address?['village'] ??
                address?['hamlet'] ??
                address?['municipality'] ??
                address?['county'] ??
                json['name'] ??
                json['display_name'])
            ?.toString();
    if (name == null || name.isEmpty) return null;

    final cc = (address?['country_code'] ?? '').toString().toUpperCase();
    final countryName = address?['country']?.toString();
    final display = json['display_name']?.toString() ?? name;

    // Mirror Placemark structure so LocationCityMatcher can apply its
    // specific→broad priority (locality > subLocality > admin areas).
    final subLocality =
        (address?['suburb'] ?? address?['neighbourhood'] ?? address?['quarter'])
            ?.toString();
    final adminArea = (address?['state'] ?? address?['region'])?.toString();
    final subAdminArea = (address?['state_district'] ?? address?['county'])
        ?.toString();

    return OnlineGeocodingResult(
      name: name,
      displayName: display,
      latitude: lat,
      longitude: lon,
      countryCode: cc,
      countryName: countryName,
      subLocality: subLocality,
      administrativeArea: adminArea,
      subAdministrativeArea: subAdminArea,
    );
  }
}
