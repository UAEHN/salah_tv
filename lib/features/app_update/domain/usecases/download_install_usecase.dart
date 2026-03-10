import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../repositories/update_repository.dart';

@injectable
class DownloadInstallUseCase {
  final UpdateRepository repository;

  DownloadInstallUseCase(this.repository);

  Future<Either<Failure, Success>> call({
    required String url,
    required Function(int, int) onProgress,
  }) async {
    final downloadResult = await repository.downloadUpdate(
      url: url,
      onProgress: onProgress,
    );

    return downloadResult.fold(
      (failure) => Left(failure),
      (filePath) => repository.installUpdate(filePath),
    );
  }
}
