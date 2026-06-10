/// Lifecycle events emitted by the ayah audio player.
enum AyahAudioStatus { idle, loading, playing, paused, completed, error }

/// Snapshot delivered on [IAyahAudioPort.events].
class AyahPlaybackEvent {
  final AyahAudioStatus status;
  final int? surahNumber;
  final int? ayahNumber;

  const AyahPlaybackEvent(this.status, {this.surahNumber, this.ayahNumber});
}

/// Per-ayah audio playback port.
///
/// Isolated from `IAudioRepository` (TV adhan/iqama/quran-stream player)
/// so completion events never bleed across feature boundaries — mirrors the
/// per-feature audio-port isolation pattern.
abstract class IAyahAudioPort {
  Stream<AyahPlaybackEvent> get events;

  /// Stops any current playback before fetching and playing the audio for
  /// [surahNumber]/[ayahNumber] from the reciter folder identified by
  /// [reciterUrlSegment]. Network or 404 failures emit a single
  /// [AyahAudioStatus.error] event and do not throw.
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String reciterUrlSegment,
  });

  /// Pauses the current playback in place (preserves position). Emits a
  /// [AyahAudioStatus.paused] event tagged with the current ayah.
  Future<void> pause();

  /// Resumes a previously paused playback. Emits [AyahAudioStatus.playing].
  Future<void> resume();

  Future<void> stop();
}
