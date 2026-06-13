import '../../../core/remote_city_catalog.dart';
import '../domain/i_city_catalog_repository.dart';
import 'datasources/city_catalog_local_data_source.dart';
import 'datasources/city_catalog_remote_data_source.dart';

/// Coordinates the remote fetch and the local cache for the city catalog.
/// Both paths are silent: any failure returns `null`, leaving the caller on
/// the bundled assets (db_city_lists.json + db_countries.json).
class CityCatalogRepository implements ICityCatalogRepository {
  CityCatalogRepository(this._remote, this._local);

  final CityCatalogRemoteDataSource _remote;
  final CityCatalogLocalDataSource _local;

  @override
  Future<RemoteCityCatalog?> loadCached() async {
    final raw = await _local.readCache();
    if (raw == null || raw.isEmpty) return null;
    try {
      return CityCatalogRemoteDataSource.parse(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RemoteCityCatalog?> refresh() async {
    try {
      final payload = await _remote.fetch();
      await _local.writeCache(payload.rawJson);
      return payload.catalog;
    } catch (_) {
      return null;
    }
  }
}
