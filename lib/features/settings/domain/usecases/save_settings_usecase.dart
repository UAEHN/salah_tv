import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../entities/app_settings.dart';
import '../i_settings_repository.dart';

class SaveSettingsUseCase {
  final ISettingsRepository repository;

  SaveSettingsUseCase(this.repository);

  Future<Either<Failure, Success>> call(AppSettings settings) =>
      repository.save(settings);
}
