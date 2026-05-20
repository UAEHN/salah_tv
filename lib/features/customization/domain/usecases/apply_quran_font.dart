import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../i_appearance_writer_port.dart';

/// Persists the user's chosen Quranic / Arabic font family.
class ApplyQuranFontUseCase {
  final IAppearanceWriterPort _writer;

  const ApplyQuranFontUseCase(this._writer);

  Future<Either<Failure, Success>> call(String family) {
    if (family.isEmpty) {
      return Future.value(const Left(CacheFailure('empty font family')));
    }
    return _writer.applyFontFamily(family);
  }
}
