/// Domain-local audio port for the prayer feature.
/// Declared here so [PrayerCycleEngine] has no cross-feature dependency
/// on the audio feature's [IAudioRepository].
/// The concrete [AudioService] satisfies this interface.
abstract class IPrayerAudioPort {
  Stream<void> get onComplete;

  Future<bool> playAdhan({String soundKey = 'default'});
  Future<bool> playDua();
  Future<bool> playIqama();
  Future<void> playPreAlertBell();
  Future<void> playPrayerAnnouncement(String prayerKey);
  Future<void> stop();

  Future<void> playQuranFromServer(String serverUrl);
  Future<void> pauseQuranPlayer();
  Future<void> resumeOrRestartQuranPlayer(String serverUrl);
  Future<void> restartQuranCurrentSurah(String serverUrl);
  Future<void> stopQuranPlayer();
}
