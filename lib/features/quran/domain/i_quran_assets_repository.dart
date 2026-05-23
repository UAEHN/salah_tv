/// On-demand QCF v2 font bundle. The reader needs `QCF_P001..QCF_P604`
/// registered as Flutter font families to render glyphs — those fonts
/// (~105 MB total) live OUTSIDE the APK and are pulled from a public
/// mirror only when the user opts in via the download gate. They land
/// in the app's documents directory and persist across launches.
///
/// Font registration is **lazy and per-page**. Registering 604 fonts up
/// front froze the UI thread for several seconds on mid-range devices
/// (every `FontLoader.load()` mutates Skia's font collection on the
/// platform thread). Pages now register their own font right before
/// they paint, and adjacent pages prefetch their fonts as the user
/// swipes.
abstract class IQuranAssetsRepository {
  /// Total number of pages in the Mushaf (always 604).
  int get totalPages;

  /// Pages whose `.woff` file is present on disk right now. Backed by a
  /// single directory listing — no per-page `File.exists()` syscalls.
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

  /// Registers the `.woff` for [pageNumber] (1..604) under the family
  /// name `QCF_P{NNN}` with the Flutter engine, if it exists on disk
  /// and is not already registered. Idempotent and cheap to call from
  /// `PageView.itemBuilder` — completes immediately on already-loaded
  /// pages.
  ///
  /// Returns `true` if the font is now available for the engine to
  /// shape (either freshly registered or already registered before),
  /// `false` if the file is missing on disk.
  Future<bool> ensureFontForPage(int pageNumber);

  /// Synchronous probe used by widgets to skip a rebuild when the font
  /// is already in the engine. Cheap — just a `Set.contains` check.
  bool isFontRegistered(int pageNumber);
}
