import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/theme_palette_info.dart';

/// Read-only catalog of theme palettes available on the **mobile** build.
/// The TV build never imports this — it consumes `kThemePalettes` directly.
abstract class IThemeCatalogRepository {
  /// Returns every palette ordered: legacy palettes first, then Islamic
  /// palettes. Implementations must guarantee unique ids.
  Future<Either<Failure, List<ThemePaletteInfo>>> getAll();
}
