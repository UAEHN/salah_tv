import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_version.dart';
import '../repositories/update_repository.dart';

class CheckUpdateUseCase {
  final UpdateRepository repository;

  CheckUpdateUseCase(this.repository);

  Future<Either<Failure, AppVersion?>> call() {
    return repository.checkForUpdate();
  }
}
