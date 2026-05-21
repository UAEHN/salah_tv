/// Local-file cache for downloaded per-ayah recitations.
///
/// Lookups are keyed by (reciter, surah, ayah). The first miss triggers
/// a network download and writes the bytes to a deterministic path; every
/// subsequent call returns that path immediately so playback is offline
/// after one tap.
abstract class IAyahAudioCache {
  /// Returns the on-disk path for the cached audio. Downloads it via the
  /// given remote `url` if not already present. Returns null when the
  /// download fails (caller should fall back to streaming).
  Future<String?> getOrDownload({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
    required String url,
  });
}
