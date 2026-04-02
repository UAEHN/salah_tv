import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/feedback_entry.dart';
import '../i_feedback_repository.dart';

class SubmitFeedbackUseCase {
  final IFeedbackRepository _repository;

  const SubmitFeedbackUseCase(this._repository);

  Future<Either<Failure, Unit>> call(FeedbackEntry entry) {
    return _repository.submit(entry);
  }
}
