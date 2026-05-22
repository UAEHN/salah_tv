import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/mushaf_glyph_page.dart';

/// Port for loading the per-page Mushaf v1 layout (lines + word codepoints).
/// Implementations also register the page font with the Flutter engine on
/// first access so the codepoints actually render.
abstract class IMushafGlyphPageRepository {
  /// Returns the [MushafGlyphPage] for [pageNumber] (1..604). Triggers a
  /// one-off `FontLoader` call so the page font is available immediately
  /// when the UI renders the result.
  Future<Either<Failure, MushafGlyphPage>> getPage(int pageNumber);

  /// Synchronous lookup for pages that are already cached AND have
  /// their font registered. Returns `null` when either side is missing.
  /// Used by the page container to skip the loading spinner on swipes
  /// where the previous prewarm already paid the load cost.
  MushafGlyphPage? cachedPage(int pageNumber);

  /// True once the asset exists locally (bundled or downloaded). Used by
  /// the reader to fall back to the legacy flowing-text page when v1
  /// data is missing.
  Future<bool> hasPage(int pageNumber);
}
