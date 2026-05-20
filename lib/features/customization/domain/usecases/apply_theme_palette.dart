import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../i_appearance_writer_port.dart';

/// Persists the user's chosen theme palette key.
/// Validation (`key` must be non-empty) lives here so adapters stay thin.
class ApplyThemePaletteUseCase {
  final IAppearanceWriterPort _writer;

  const ApplyThemePaletteUseCase(this._writer);

  Future<Either<Failure, Success>> call(String key) {
    if (key.isEmpty) {
      return Future.value(const Left(CacheFailure('empty theme key')));
    }
    return _writer.applyThemeKey(key);
  }
}
