/// Isolated audio port for adhkar playback.
/// Kept separate from [IAudioRepository] so adhkar completion events
/// never reach the prayer cycle engine's [onComplete] listener.
abstract class IAdhkarAudioPort {
  /// Fires once when the current dhikr audio file finishes naturally.
  Stream<void> get onComplete;

  /// Plays the audio at [url]. Network failure is silently swallowed —
  /// the caller must start a fallback timer if this does not trigger [onComplete].
  Future<void> play(String url);

  Future<void> stop();
}
