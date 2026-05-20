import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/remote_version_info.dart';

/// Fetches the latest published version metadata from a remote source
/// (Firebase Remote Config). Implementations must never throw — failures
/// are wrapped in [Failure].
abstract class IRemoteVersionRepository {
  Future<Either<Failure, RemoteVersionInfo>> fetchLatest();
}
