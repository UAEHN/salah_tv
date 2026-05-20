import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/quran_font_info.dart';

/// Read-only catalog of Quranic / Arabic fonts available on the mobile build.
abstract class IQuranFontCatalogRepository {
  /// Returns every available font family. The selected family is persisted
  /// in `AppSettings.fontFamily` and resolved by Flutter via `pubspec.yaml`.
  Future<Either<Failure, List<QuranFontInfo>>> getAll();
}
