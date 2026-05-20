import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/quran_font_info.dart';
import '../domain/i_quran_font_catalog_repository.dart';

/// Static catalog of font families bundled in `pubspec.yaml`.
/// Every id here MUST exist in `pubspec.yaml` under `flutter.fonts.family`,
/// otherwise Flutter will silently fall back to the default font and the
/// preview would be misleading. Adding a new font means: ship the asset,
/// register it in `pubspec.yaml`, then add the entry below.
const List<QuranFontInfo> _kBundledFonts = [
  QuranFontInfo(id: 'Kufi', labelKey: 'fontKufi', hintKey: 'fontHintKufi'),
  QuranFontInfo(id: 'Cairo', labelKey: 'fontCairo', hintKey: 'fontHintCairo'),
  QuranFontInfo(
    id: 'Beiruti',
    labelKey: 'fontBeiruti',
    hintKey: 'fontHintBeiruti',
  ),
  QuranFontInfo(id: 'Rubik', labelKey: 'fontRubik', hintKey: 'fontHintRubik'),
  QuranFontInfo(id: 'Inter', labelKey: 'fontInter', hintKey: 'fontHintInter'),
];

class QuranFontCatalogRepositoryImpl implements IQuranFontCatalogRepository {
  const QuranFontCatalogRepositoryImpl();

  @override
  Future<Either<Failure, List<QuranFontInfo>>> getAll() async {
    try {
      if (_kBundledFonts.isEmpty) {
        return const Left(CacheFailure('empty font catalog'));
      }
      // Defensive copy so consumers cannot mutate the const list.
      return Right(List<QuranFontInfo>.unmodifiable(_kBundledFonts));
    } on Object catch (e) {
      return Left(CacheFailure('font catalog error: $e'));
    }
  }
}
