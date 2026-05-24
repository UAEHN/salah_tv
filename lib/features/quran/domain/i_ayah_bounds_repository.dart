import 'entities/ayah_glyph_bounds.dart';

/// Per-glyph bounding-box index for the Madinah Mushaf page images.
///
/// Backed by the `ayahinfo_1024.db` SQLite shipped alongside the
/// `width_1024` page PNGs by the quran_android project. The DB lists
/// every word's pixel rectangle on every page, indexed by surah/ayah.
/// We use it for two things:
///   * **Tap-to-play**: convert a tap on the page widget to image
///     pixel coordinates, then look up which (sura, ayah) glyph owns
///     that point.
///   * **Playing-ayah highlight**: draw colored rectangles over every
///     glyph of the currently-playing ayah on the visible page.
///
/// The database lives in the app's documents directory and persists
/// across launches. First open downloads the 2.2 MB zip + extracts;
/// subsequent opens are local-only.
abstract class IAyahBoundsRepository {
  /// Canonical pixel dimensions of every page image at `width_1024`.
  /// Used to map between widget-local coordinates (after BoxFit.contain
  /// scaling) and the SQLite's image-pixel coordinates.
  static const int pageImageWidth = 1024;
  static const int pageImageHeight = 1656;

  /// Cheap check — `true` once the DB file is on disk and the
  /// connection is open. Tap-to-play stays a no-op until this flips.
  bool get isReady;

  /// Idempotent. First call downloads + extracts the zip then opens
  /// the DB; later calls return immediately. Safe to fire-and-forget
  /// from the reader's `initState`.
  Future<void> ensureReady();

  /// Returns the (sura, ayah) at the given image-pixel coordinate on
  /// [pageNumber], or `null` if no glyph covers that point. Both
  /// coordinates are in the SAME pixel space as [pageImageWidth] /
  /// [pageImageHeight] (i.e. caller must scale tap → image first).
  Future<({int sura, int ayah})?> hitTest({
    required int pageNumber,
    required int imageX,
    required int imageY,
  });

  /// Every glyph rectangle that belongs to (sura, ayah) on
  /// [pageNumber] — used by the highlight overlay. Empty if the ayah
  /// has no glyphs on the page (verse split across pages).
  Future<List<AyahGlyphBounds>> glyphsForAyah({
    required int pageNumber,
    required int sura,
    required int ayah,
  });
}
