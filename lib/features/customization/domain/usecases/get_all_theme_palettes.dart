import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/theme_palette_info.dart';
import '../i_theme_catalog_repository.dart';

/// Returns all selectable theme palettes, ordered legacy-first.
/// Pure delegation to [IThemeCatalogRepository] — kept as a use-case so the
/// presentation layer never imports the data layer directly (CLAUDE.md §3).
class GetAllThemePalettesUseCase {
  final IThemeCatalogRepository _repo;

  const GetAllThemePalettesUseCase(this._repo);

  Future<Either<Failure, List<ThemePaletteInfo>>> call() => _repo.getAll();
}
