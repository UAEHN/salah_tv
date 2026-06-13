import '../../../core/remote_city_catalog.dart';

/// Source of the remote city picker catalog. Implementations never throw —
/// every failure collapses to `null` so the caller falls back to bundled assets.
abstract class ICityCatalogRepository {
  /// Reads the last cached catalog (no network). `null` when absent or invalid.
  Future<RemoteCityCatalog?> loadCached();

  /// Fetches the latest catalog and caches it on success.
  /// Returns the fresh catalog, or `null` on any network/parse failure.
  Future<RemoteCityCatalog?> refresh();
}
