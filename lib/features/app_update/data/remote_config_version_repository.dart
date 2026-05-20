import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/remote_version_info.dart';
import '../domain/i_remote_version_repository.dart';
import 'datasources/remote_config_data_source.dart';

/// Repository over [RemoteConfigDataSource]. Catches typed exceptions and
/// returns `Either<Failure, RemoteVersionInfo>` per architecture rules.
class RemoteConfigVersionRepository implements IRemoteVersionRepository {
  RemoteConfigVersionRepository(this._dataSource);

  final RemoteConfigDataSource _dataSource;

  @override
  Future<Either<Failure, RemoteVersionInfo>> fetchLatest() async {
    try {
      return Right(_dataSource.read());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
