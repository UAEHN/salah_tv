import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/remote_city_result.dart';
import 'remote_search_cancel_token.dart';

abstract class IRemoteCitySearchRepository {
  Future<Either<Failure, List<RemoteCityResult>>> search(
    String query, {
    RemoteSearchCancelToken? cancelToken,
  });
}
