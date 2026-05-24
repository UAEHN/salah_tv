/// On-disk store for the 604 Madinah Mushaf page PNGs pulled from
/// files.quran.app. Images persist in the app's documents directory
/// — not the OS cache — so the reader keeps working offline even if
/// Android reclaims cache space.
///
/// Modes of operation:
///   * **On-demand** — [ensurePage] downloads a single page the
///     first time it's requested, then returns its local path on
///     every subsequent call.
///   * **Bulk pre-fetch** — [downloadAll] streams the running count
///     of downloaded pages, used by the optional "download whole
///     Mushaf for offline" flow.
///
/// Both flows share the same on-disk layout so a page pulled by one
/// is visible to the other without re-downloading.
abstract class IPageImageRepository {
  /// Total page count (always 604).
  int get totalPages;

  /// Pages whose PNG is on disk right now. Single directory listing —
  /// no 604 separate `File.exists` calls.
  Future<int> downloadedCount();

  /// `true` when every page PNG is on disk.
  Future<bool> isComplete();

  /// Resolves to the absolute file path for [pageNumber]. Downloads
  /// the file if it's not yet cached. Idempotent and coalesced —
  /// concurrent callers for the same page share one HTTP request.
  Future<String> ensurePage(int pageNumber);

  /// Streams the running count of downloaded pages while a bulk
  /// download runs. Resumable: already-cached pages are counted and
  /// skipped. Errors propagate via the stream's onError.
  Stream<int> downloadAll();

  /// Wipes every cached PNG. Used by the "free up space" action on
  /// the Quran-tab storage card. Idempotent — silently succeeds if
  /// the cache directory doesn't exist.
  Future<void> deleteAll();
}
