import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import 'entities/app_settings.dart';

abstract class ISettingsRepository {
  Future<Either<Failure, AppSettings>> load();
  Future<Either<Failure, Success>> save(AppSettings settings);
  Future<bool> isFirstLaunch();
  Future<void> markLaunched();
}
