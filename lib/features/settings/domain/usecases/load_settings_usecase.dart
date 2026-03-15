import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../i_settings_repository.dart';

class LoadSettingsUseCase {
  final ISettingsRepository repository;

  LoadSettingsUseCase(this.repository);

  Future<Either<Failure, AppSettings>> call() => repository.load();
}
