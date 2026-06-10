import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/remote_occasion_dto.dart';
import 'occasions_remote_data_source.dart';

/// Two-tier local fallback for the occasions catalog:
///   1. SharedPreferences cache (last successful download)
///   2. Bundled asset shipped with the APK (`assets/occasions/occasions_default.json`)
///
/// Either tier returns parsed `RemoteOccasionDto`s ready for the repository
/// to filter & convert. Failures collapse to an empty list — the repository
/// then has nothing to match against and surfaces `null` (no occasion).
class OccasionsLocalDataSource {
  OccasionsLocalDataSource({String? bundledAssetPath})
    : _bundledAssetPath =
          bundledAssetPath ?? 'assets/occasions/occasions_default.json';

  static const _cacheJsonKey = 'occasions_cache_json';
  static const _cacheEtagKey = 'occasions_cache_etag';

  final String _bundledAssetPath;

  Future<String?> readCachedEtag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheEtagKey);
  }

  Future<void> writeCache(String rawJson, String? etag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheJsonKey, rawJson);
    if (etag == null || etag.isEmpty) {
      await prefs.remove(_cacheEtagKey);
    } else {
      await prefs.setString(_cacheEtagKey, etag);
    }
  }

  Future<List<RemoteOccasionDto>> readCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheJsonKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return OccasionsRemoteDataSource.parse(raw).occasions;
    } catch (_) {
      return const [];
    }
  }

  Future<List<RemoteOccasionDto>> readBundled() async {
    try {
      final raw = await rootBundle.loadString(_bundledAssetPath);
      return OccasionsRemoteDataSource.parse(raw).occasions;
    } catch (_) {
      return const [];
    }
  }
}
