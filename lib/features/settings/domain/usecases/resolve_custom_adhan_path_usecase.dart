import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../i_custom_adhan_repository.dart';

class ResolveCustomAdhanPathUseCase {
  final ICustomAdhanRepository _repo;
  const ResolveCustomAdhanPathUseCase(this._repo);

  Future<Either<Failure, String>> call(String fileName) =>
      _repo.absolutePathOf(fileName);
}
