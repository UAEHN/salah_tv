import 'package:flutter/foundation.dart';

import '../../features/settings/data/city_catalog_repository.dart';
import '../../features/settings/data/datasources/city_catalog_local_data_source.dart';
import '../../features/settings/data/datasources/city_catalog_remote_data_source.dart';
import '../../features/settings/domain/i_city_catalog_repository.dart';
import '../../injection.dart';
import '../city_translations.dart';

/// Registers the city-catalog repository and merges the *cached* remote catalog
/// over the bundled city lists. Cache-only (no network) so boot is never
/// blocked — the bundled assets remain the floor when no cache exists.
///
/// Must run AFTER [loadCityTranslations] (which sets the bundled baseline).
Future<void> applyCachedCityCatalog() async {
  try {
    final repo = CityCatalogRepository(
      CityCatalogRemoteDataSource(),
      CityCatalogLocalDataSource(),
    );
    getIt.registerSingleton<ICityCatalogRepository>(repo);

    final cached = await repo.loadCached();
    if (cached != null) mergeRemoteCatalog(cached);
  } catch (e) {
    if (kDebugMode) debugPrint('[CityCatalog] apply cached failed: $e');
  }
}

/// Fire-and-forget refresh of the remote catalog. Updates the cache for next
/// launch and re-merges in-memory so a picker opened later this session also
/// sees freshly-published cities. Silent on any failure (offline, bad publish).
Future<void> primeCityCatalog() async {
  try {
    final fresh = await getIt<ICityCatalogRepository>().refresh();
    if (fresh != null) mergeRemoteCatalog(fresh);
  } catch (e) {
    if (kDebugMode) debugPrint('[CityCatalog] prime failed: $e');
  }
}
