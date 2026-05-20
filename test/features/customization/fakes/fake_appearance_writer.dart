import 'package:dartz/dartz.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/usecases/success.dart';
import 'package:ghasaq/features/customization/domain/i_appearance_writer_port.dart';

/// Hand-rolled fake (CLAUDE.md §13.16) — no mockito generation needed.
class FakeAppearanceWriter implements IAppearanceWriterPort {
  /// History of every key written via `applyThemeKey`.
  final List<String> themeKeysWritten = [];
  final List<String> fontFamiliesWritten = [];

  /// When non-null, the next call returns this `Left(failure)` instead.
  Failure? nextFailure;

  @override
  Future<Either<Failure, Success>> applyThemeKey(String key) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Left(f);
    }
    themeKeysWritten.add(key);
    return const Right(Success());
  }

  @override
  Future<Either<Failure, Success>> applyFontFamily(String family) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Left(f);
    }
    fontFamiliesWritten.add(family);
    return const Right(Success());
  }
}
