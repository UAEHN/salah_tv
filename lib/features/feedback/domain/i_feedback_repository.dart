import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'entities/feedback_entry.dart';

abstract interface class IFeedbackRepository {
  Future<Either<Failure, Unit>> submit(FeedbackEntry entry);
}
