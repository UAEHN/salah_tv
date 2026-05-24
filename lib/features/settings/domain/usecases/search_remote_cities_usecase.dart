import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/remote_city_result.dart';
import '../i_remote_city_search_repository.dart';
import '../remote_search_cancel_token.dart';

class SearchRemoteCitiesUseCase {
  final IRemoteCitySearchRepository _repo;
  const SearchRemoteCitiesUseCase(this._repo);

  Future<Either<Failure, List<RemoteCityResult>>> call(
    String query, {
    RemoteSearchCancelToken? cancelToken,
  }) {
    final trimmed = query.trim();
    if (trimmed.length < 2) return Future.value(const Right([]));
    return _repo.search(trimmed, cancelToken: cancelToken);
  }
}
