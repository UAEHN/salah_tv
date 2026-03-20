import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../repositories/update_repository.dart';

class DownloadInstallUseCase {
  final UpdateRepository repository;

  DownloadInstallUseCase(this.repository);

  Future<Either<Failure, Success>> call({
    required String url,
    required Function(int, int) onProgress,
    void Function()? onBeforeInstall,
  }) async {
    final downloadResult = await repository.downloadUpdate(
      url: url,
      onProgress: onProgress,
    );

    return downloadResult.fold(
      (failure) => Left(failure),
      (filePath) async {
        onBeforeInstall?.call();
        return repository.installUpdate(filePath);
      },
    );
  }
}
