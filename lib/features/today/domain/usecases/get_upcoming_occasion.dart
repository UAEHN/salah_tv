import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/upcoming_occasion.dart';
import '../i_islamic_occasions_repository.dart';

class GetUpcomingOccasionUseCase {
  final IIslamicOccasionsRepository _repo;

  const GetUpcomingOccasionUseCase(this._repo);

  Future<Either<Failure, UpcomingOccasion?>> call({DateTime? now}) {
    return _repo.getNextOccasion(now ?? DateTime.now());
  }
}
