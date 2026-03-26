import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_prayer_times.dart';
import '../i_prayer_times_repository.dart';

class GetPrayerTimesByDateUseCase {
  final IPrayerTimesRepository _repository;

  const GetPrayerTimesByDateUseCase(this._repository);

  Future<Either<Failure, DailyPrayerTimes?>> call(DateTime date) {
    return _repository.getByDate(date);
  }
}
