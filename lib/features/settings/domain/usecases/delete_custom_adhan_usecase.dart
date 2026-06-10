import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/custom_adhan.dart';
import '../i_custom_adhan_repository.dart';

class DeleteCustomAdhanUseCase {
  final ICustomAdhanRepository _repo;
  const DeleteCustomAdhanUseCase(this._repo);

  Future<Either<Failure, Unit>> call(CustomAdhan adhan) =>
      _repo.deleteFile(fileName: adhan.fileName, contentUri: adhan.contentUri);
}
