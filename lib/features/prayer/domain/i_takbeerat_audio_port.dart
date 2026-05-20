/// Domain-local audio port for the Eid Takbeerat track.
///
/// Sits next to [IPrayerAudioPort] so [PrayerCycleEngine] can coordinate
/// pause/resume against the prayer cycle without the engine depending on
/// the audio or takbeerat features.
///
/// All methods are async no-ops when the implementation has no track to
/// play (mobile / empty URL) — never throws.
abstract class ITakbeeratAudioPort {
  /// True between [play] and [stop] / natural completion.
  bool get isPlaying;

  /// Streams a takbeerat track from [url] in a loop until [stop] is called
  /// or the cycle pauses it. Replaces any previously-playing track.
  Future<void> play(String url);

  /// Pauses without losing the playback position. Used when the prayer
  /// cycle takes over (adhan/dua/iqama).
  Future<void> pause();

  /// Resumes from the paused position. Safe to call when not paused — it
  /// becomes a no-op.
  Future<void> resume();

  /// Fully stops and releases the underlying resources. The next [play]
  /// starts from the beginning.
  Future<void> stop();
}
