import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/takbeerat_config.dart';

/// Loads the Eid Takbeerat [TakbeeratConfig] from Remote Config.
/// Implementations must never throw — failures are wrapped in [Failure].
abstract class ITakbeeratConfigRepository {
  Future<Either<Failure, TakbeeratConfig>> fetchConfig();
}
