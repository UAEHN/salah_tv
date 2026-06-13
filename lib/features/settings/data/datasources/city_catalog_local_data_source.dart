import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last successfully-downloaded city catalog as a raw JSON string
/// in SharedPreferences. Mirrors the occasions cache pattern.
///
/// The cache key carries a schema-version suffix (`_v1`): bumping the catalog
/// schema bumps the key so a stale-shaped payload is never deserialized after
/// an update (§11 versioned cache keys).
class CityCatalogLocalDataSource {
  static const _cacheKey = 'city_catalog_cache_json_v1';

  Future<void> writeCache(String rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, rawJson);
  }

  Future<String?> readCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheKey);
  }
}
