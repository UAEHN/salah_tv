import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/quran_font_info.dart';
import '../i_quran_font_catalog_repository.dart';

/// Returns all selectable Arabic / Quranic fonts.
class GetAllQuranFontsUseCase {
  final IQuranFontCatalogRepository _repo;

  const GetAllQuranFontsUseCase(this._repo);

  Future<Either<Failure, List<QuranFontInfo>>> call() => _repo.getAll();
}
