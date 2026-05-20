import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/takbeerat_config.dart';
import '../domain/i_takbeerat_config_repository.dart';
import 'datasources/takbeerat_remote_config_data_source.dart';

/// Wraps [TakbeeratRemoteConfigDataSource] and surfaces typed failures —
/// follows the same shape as [RemoteConfigVersionRepository].
class TakbeeratConfigRepository implements ITakbeeratConfigRepository {
  TakbeeratConfigRepository(this._dataSource);

  final TakbeeratRemoteConfigDataSource _dataSource;

  @override
  Future<Either<Failure, TakbeeratConfig>> fetchConfig() async {
    try {
      return Right(_dataSource.read());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
