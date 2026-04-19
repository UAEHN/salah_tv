import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/custom_adhan.dart';
import '../i_custom_adhan_repository.dart';

class ImportCustomAdhanUseCase {
  final ICustomAdhanRepository _repo;
  const ImportCustomAdhanUseCase(this._repo);

  Future<Either<Failure, CustomAdhan>> call(String srcPath, String label) =>
      _repo.importFromPath(srcPath, label);
}
