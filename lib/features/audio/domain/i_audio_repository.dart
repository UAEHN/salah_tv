abstract class IAudioRepository {
  bool get isPlaying;
  Stream<void> get onComplete;
  int get quranSurahIndex;

  Future<bool> playAdhan({String soundKey = 'default'});
  Future<bool> playDua();
  Future<bool> playIqama({String soundKey = 'default'});
  Future<void> playPrayerAnnouncement(String prayerKey);
  Future<void> stop();

  Stream<void> get onQuranError;
  Stream<bool> get onQuranLoading;

  Future<void> playQuranFromServer(String serverUrl);
  Future<void> pauseQuranPlayer();
  Future<void> resumeOrRestartQuranPlayer(String serverUrl);
  Future<void> restartQuranCurrentSurah(String serverUrl);
  Future<void> resumeQuranPlayer();
  Future<void> stopQuranPlayer();

  void dispose();
}
