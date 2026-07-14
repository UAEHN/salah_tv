import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/diagnostics/report_fault.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../cancellation_token.dart';
import '../i_prayer_city_downloader.dart';
import '../../data/prayer_cache_db_queries.dart';
import '../../data/prayer_cache_db_writer.dart';
import 'i_download_city_use_case.dart';

class DownloadCityUseCase implements IDownloadCityUseCase {
  DownloadCityUseCase(this._db, this._queries, this._downloader, this._writer);

  final Database _db;
  final PrayerCacheDbQueries _queries;
  final IPrayerCityDownloader _downloader;
  final PrayerCacheDbWriter _writer;

  @override
  Future<Either<Failure, Success>> call({
    required String countryKey,
    required String cityName,
    required CancellationToken cancelToken,
  }) async {
    try {
      final slug = _slug(cityName);
      final countryId = await _queries.upsertCountry(_db, countryKey);
      final cityId = await _queries.upsertCity(_db, countryId, cityName);

      final cachedHash = await _queries.getCachedHash(_db, cityId);

      if (cancelToken.isCancelled) return const Left(CancelledFailure());

      final result = await _downloader.fetchCity(countryKey, slug, cancelToken);

      return await result.fold((failure) async => Left(failure), (
        payload,
      ) async {
        if (cachedHash == payload.hash) {
          return const Right(Success());
        }

        if (cancelToken.isCancelled) return const Left(CancelledFailure());

        // The write/mark step touches the local DB, NOT the network. Guard it
        // separately so a storage failure (disk full, DB locked/corrupt) is
        // reported as such — the outer catch would otherwise mislabel it a
        // "network" failure and tell the user to check their connection while
        // the real cause (device storage) stays invisible.
        try {
          await _writer.writeCityRows(_db, cityId, payload.rows, cancelToken);
          await _queries.markCityCached(
            _db,
            cityId,
            DateTime.now().year,
            payload.hash,
          );
        } on CancellationException {
          return const Left(CancelledFailure());
        } catch (e) {
          reportFaultError(
            'city_download_write_failed',
            fields: {'city': cityName, 'country': countryKey},
            error: e,
          );
          return Left(CacheFailure('Failed to store city data: $e'));
        }
        return const Right(Success());
      });
    } on CancellationException {
      return const Left(CancelledFailure());
    } catch (e) {
      return Left(NetworkFailure('Download failed: $e'));
    }
  }

  String _slug(String cityName) =>
      cityName.toLowerCase().replaceAll("'", '').replaceAll(' ', '_');
}
