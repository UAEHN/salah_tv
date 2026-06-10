import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/online_geocoding_result.dart';
import '../domain/i_online_geocoding_repository.dart';
import 'online_geocoding_data_source.dart';

class OnlineGeocodingRepository implements IOnlineGeocodingRepository {
  OnlineGeocodingRepository(this._dataSource);

  final OnlineGeocodingDataSource _dataSource;

  @override
  Future<Either<Failure, List<OnlineGeocodingResult>>> search(
    String query, {
    String? countryCode,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const Right([]);
    try {
      final results = await _dataSource.search(
        trimmed,
        countryCode: countryCode,
      );
      return Right(results);
    } on ServerException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, OnlineGeocodingResult?>> reverse({
    required double latitude,
    required double longitude,
    String? localeHint,
  }) async {
    try {
      final result = await _dataSource.reverse(
        latitude: latitude,
        longitude: longitude,
        localeHint: localeHint,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('$e'));
    }
  }
}
