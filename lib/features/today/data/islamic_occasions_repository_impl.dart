import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../core/error/failures.dart';
import '../../app_update/domain/i_app_version_info_port.dart';
import '../domain/constants/today_constants.dart';
import '../domain/entities/upcoming_occasion.dart';
import '../domain/i_islamic_occasions_repository.dart';
import 'datasources/occasions_local_data_source.dart';
import 'datasources/occasions_remote_data_source.dart';
import 'models/remote_occasion_dto.dart';

/// Resolves the next Hijri occasion by walking forward day-by-day from
/// [from] and matching each day's `(hMonth, hDay)` against the loaded
/// catalog.
///
/// Catalog sources, in fall-through order:
///   1. Remote `occasions/manifest.json` (cached in SharedPreferences).
///   2. Last successful cache (offline / fetch failed).
///   3. Bundled asset (`assets/occasions/occasions_default.json`) — ships
///      with the APK so a fresh install with no network still has data.
class IslamicOccasionsRepositoryImpl implements IIslamicOccasionsRepository {
  IslamicOccasionsRepositoryImpl({
    required OccasionsRemoteDataSource remoteSource,
    required OccasionsLocalDataSource localSource,
    required IAppVersionInfoPort versionInfo,
  }) : _remote = remoteSource,
       _local = localSource,
       _versionInfo = versionInfo;

  final OccasionsRemoteDataSource _remote;
  final OccasionsLocalDataSource _local;
  final IAppVersionInfoPort _versionInfo;

  List<UpcomingOccasion>? _catalog;
  int? _buildNumber;
  Future<void>? _inflightLoad;

  /// Fetches the remote catalog and refreshes the in-memory list + cache.
  /// Safe to call from startup; failures fall back to cache → bundled asset.
  /// Concurrent calls coalesce into one inflight future.
  Future<void> loadCatalog({bool forceRefresh = false}) {
    if (!forceRefresh && _catalog != null) return Future.value();
    _inflightLoad ??= _doLoad().whenComplete(() => _inflightLoad = null);
    return _inflightLoad!;
  }

  Future<void> _doLoad() async {
    _buildNumber ??= await _versionInfo.currentBuildNumber();
    final dtos = await _fetchDtos();
    _catalog = dtos
        .where((d) => d.matchesVersion(_buildNumber ?? 0))
        .map((d) => d.toEntity())
        .toList(growable: false);
    if (kDebugMode) {
      debugPrint(
        '[OccasionsRepo] catalog loaded — ${_catalog!.length} entries '
        '(buildNumber=$_buildNumber)',
      );
    }
  }

  Future<List<RemoteOccasionDto>> _fetchDtos() async {
    try {
      final payload = await _remote.fetch();
      await _local.writeCache(payload.rawJson, payload.etag);
      return payload.occasions;
    } catch (_) {
      final cached = await _local.readCached();
      if (cached.isNotEmpty) return cached;
      return await _local.readBundled();
    }
  }

  @override
  Future<Either<Failure, UpcomingOccasion?>> getNextOccasion(
    DateTime from,
  ) async {
    try {
      if (_catalog == null) await loadCatalog();
      final catalog = _catalog ?? const <UpcomingOccasion>[];
      if (catalog.isEmpty) return const Right(null);

      final localFrom = DateTime(from.year, from.month, from.day);
      // Walk day-by-day up to the configured window. For each Gregorian day
      // compute its Hijri counterpart and look it up in the catalog. We
      // intentionally avoid the inverse direction (Hijri → Gregorian) because
      // the `hijri` package's reverse calendar can drift across implementations
      // — Gregorian-driven walking guarantees we honour the device's Hijri
      // anchor and stays correct around month boundaries.
      for (var offset = 0; offset <= kUpcomingOccasionWindowDays; offset++) {
        final candidate = localFrom.add(Duration(days: offset));
        final hijri = HijriCalendar.fromDate(candidate);
        final match = _findCatalogMatch(catalog, hijri.hMonth, hijri.hDay);
        if (match != null) {
          return Right(match.copyWithDaysUntil(offset));
        }
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure('occasions lookup error: $e'));
    }
  }

  UpcomingOccasion? _findCatalogMatch(
    List<UpcomingOccasion> catalog,
    int hMonth,
    int hDay,
  ) {
    for (final occasion in catalog) {
      if (occasion.hijriMonth == hMonth && occasion.hijriDay == hDay) {
        return occasion;
      }
    }
    return null;
  }
}
