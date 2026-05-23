/// On-demand QCF v2 font bundle. The reader needs `QCF_P001..QCF_P604`
/// registered as Flutter font families to render glyphs — those fonts
/// (~105 MB total) live OUTSIDE the APK and are pulled from a public
/// mirror only when the user opts in via the download gate. They land
/// in the app's documents directory and persist across launches.
abstract class IQuranAssetsRepository {
  /// Total number of pages in the Mushaf (always 604).
  int get totalPages;

  /// Pages whose `.woff` file is present on disk right now.
  Future<int> downloadedCount();

  /// Convenience: `true` when every page font is on disk.
  Future<bool> isComplete();

  /// Streams the running count of downloaded pages while the download
  /// runs. Each emit reflects a newly-finished page. Resumable: if
  /// some pages already exist on disk, they're counted and skipped.
  Stream<int> download();

  /// Wipes every downloaded `.woff`. The fonts already registered with
  /// the Flutter engine stay live until the next app restart — there
  /// is no public API to unregister a font in Flutter, so the reader
  /// keeps working in-session but a relaunch shows the download gate
  /// again.
  Future<void> deleteAll();

  /// Registers every present `.woff` with the Flutter engine under the
  /// family name `QCF_P{NNN}` so the reader's `RichText` renders. Safe
  /// to call multiple times — already-registered pages are skipped.
  Future<void> registerAllFonts();
}
