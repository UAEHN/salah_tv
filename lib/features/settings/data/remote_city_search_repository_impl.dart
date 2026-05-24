import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/remote_city_result.dart';
import '../domain/i_remote_city_search_repository.dart';
import '../domain/remote_search_cancel_token.dart';
import 'datasources/nominatim_remote_datasource.dart';
import 'remote_city_lru_cache.dart';

class RemoteCitySearchRepositoryImpl implements IRemoteCitySearchRepository {
  final NominatimRemoteDataSource _datasource;
  final RemoteCityLruCache _cache;

  const RemoteCitySearchRepositoryImpl(this._datasource, this._cache);

  @override
  Future<Either<Failure, List<RemoteCityResult>>> search(
    String query, {
    RemoteSearchCancelToken? cancelToken,
  }) async {
    final cached = _cache.get(query);
    if (cached != null) return Right(cached);

    final dioToken = CancelToken();
    // Bridge the domain-level token to dio's CancelToken so a cancelled
    // search aborts the in-flight HTTP request.
    cancelToken?.whenCancelled.then((_) {
      if (!dioToken.isCancelled) dioToken.cancel('caller cancelled');
    });

    try {
      final models = await _datasource.search(query, cancelToken: dioToken);
      final results = models
          .map((m) => m.toEntity())
          .whereType<RemoteCityResult>()
          .toList();
      _cache.put(query, results);
      return Right(results);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const Left(CancelledFailure());
      }
      if (e.error is SocketException) {
        return Left(NetworkFailure(e.message ?? 'No network'));
      }
      return Left(ServerFailure(e.message ?? 'Search failed'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
