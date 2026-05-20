/// How the Quran audio is played in the background.
enum QuranPlaybackMode {
  /// Continuous full-Mushaf streaming (1→2→…→114→1 indefinitely).
  continuous,

  /// User-selected single surah, played [surahRepeatCount] times then stops.
  singleSurah,

  /// User-defined playlist, played [playlistCycleCount] times then stops.
  playlist,
}

/// Sentinel for an unbounded repeat count.
const int kInfiniteRepeat = -1;

/// Start-position strategy when [QuranPlaybackMode.continuous] is selected.
enum ContinuousStartMode {
  /// Resume from the last surah that was playing — best for users who listen
  /// in sessions across days. Default.
  resume,

  /// Always start from Al-Fatiha (surah 1), then read 1→2→…→114 in order.
  /// Each new session restarts from the beginning.
  fromStart,

  /// Pick surahs in random order — fresh order each surah completion.
  random,
}
