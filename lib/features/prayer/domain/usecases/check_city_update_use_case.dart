import 'package:sqflite/sqflite.dart';

import '../cancellation_token.dart';
import '../i_prayer_city_downloader.dart';
import '../../data/prayer_cache_db_queries.dart';
import 'download_city_use_case.dart';

/// Silently checks whether the active city's prayer data needs updating.
///
/// Fetches manifest.json and compares the remote hash against the local
/// cached hash. On any error (network, parse, timeout) → returns silently.
/// Never throws; never shows UI.
class CheckCityUpdateUseCase {
  CheckCityUpdateUseCase(
    this._db,
    this._queries,
    this._downloader,
    this._downloadUseCase,
  );

  final Database _db;
  final PrayerCacheDbQueries _queries;
  final IPrayerCityDownloader _downloader;
  final DownloadCityUseCase _downloadUseCase;

  Future<void> call({
    required String countryKey,
    required String cityName,
  }) async {
    try {
      final manifest = await _downloader.fetchManifest();
      if (manifest == null) return;

      final slug = _slug(cityName);
      final remoteHash = manifest['$countryKey/$slug'];
      if (remoteHash == null) return;

      final cityId = await _queries.getCityId(_db, countryKey, cityName);
      if (cityId == null) return;

      final localHash = await _queries.getCachedHash(_db, cityId);
      if (localHash == remoteHash) return;

      await _downloadUseCase(
        countryKey: countryKey,
        cityName: cityName,
        cancelToken: CancellationToken(),
      );
    } catch (_) {
      // Silent — background check must never surface errors.
    }
  }

  String _slug(String cityName) =>
      cityName.toLowerCase().replaceAll("'", '').replaceAll(' ', '_');
}
