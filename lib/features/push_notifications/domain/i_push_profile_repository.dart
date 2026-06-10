import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/push_profile.dart';

/// Write-only port: the device pushes its profile up; it never reads
/// other users' profiles. Cloud Functions are the sole reader.
abstract class IPushProfileRepository {
  Future<Either<Failure, Unit>> save(PushProfile profile);
}
