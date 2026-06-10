import 'entities/audio_output_state.dart';

/// Resolver consulted after each Quran surah finishes. Returns the next surah
/// number (1..114) to play, or null to stop. Null resolver = default rolling.
typedef NextSurahResolver = int? Function(int currentSurahNumber);

/// Domain-local audio port for the prayer feature.
/// Declared here so [PrayerCycleEngine] has no cross-feature dependency
/// on the audio feature's [IAudioRepository].
/// The concrete [AudioService] satisfies this interface.
abstract class IPrayerAudioPort {
  Stream<void> get onComplete;

  Future<bool> playAdhan({String soundKey = 'default'});
  Future<bool> playDua();
  Future<bool> playIqama();

  /// Reads the current media-output state so the engine can flag a played-but-
  /// inaudible adhan (muted / zero volume). Returns null when the platform
  /// can't report it (e.g. the mobile no-op port, where sound is carried by
  /// native notifications instead).
  Future<AudioOutputState?> readAudioOutputState();
  Future<void> playPreAlertBell();
  Future<void> playPrayerAnnouncement(String prayerKey);
  Future<void> stop();

  Future<void> playQuranFromServer(String serverUrl);
  Future<void> playQuranSurah(String serverUrl, int surahNumber);
  Future<void> pauseQuranPlayer();
  Future<void> resumeOrRestartQuranPlayer(String serverUrl);
  Future<void> restartQuranCurrentSurah(String serverUrl);
  Future<void> stopQuranPlayer();

  /// 1..114 — null when no Quran is currently playing.
  int? get currentQuranSurah;

  /// Emits the surah number that just finished playing.
  Stream<int> get onQuranSurahCompleted;

  /// Sets the strategy used to pick the next surah after one finishes.
  /// Pass null to restore default continuous (1→2→…→114→1).
  void setQuranNextSurahResolver(NextSurahResolver? resolver);
}
