import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../entities/app_version.dart';

abstract class UpdateRepository {
  Future<Either<Failure, AppVersion?>> checkForUpdate();
  Future<Either<Failure, String>> downloadUpdate({
    required String url,
    required Function(int, int) onProgress,
  });
  Future<Either<Failure, Success>> installUpdate(String filePath);
}
