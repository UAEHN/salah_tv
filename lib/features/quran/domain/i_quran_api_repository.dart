import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'entities/quran_reciter.dart';

abstract class IQuranApiRepository {
  Future<Either<Failure, List<QuranApiReciter>>> fetchReciters();
  Future<Either<Failure, List<QuranApiReciter>>> refreshReciters();
}
