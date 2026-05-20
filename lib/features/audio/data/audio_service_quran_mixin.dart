import '../../prayer/domain/i_prayer_audio_port.dart';
import 'quran_audio_service.dart';

/// Pure delegation of [IAudioRepository]/[IPrayerAudioPort] Quran-stream
/// methods to an internal [QuranAudioService]. Split into a mixin so that
/// `audio_service.dart` stays under the 150-line cap without changing any
/// behavior. Concrete classes must expose `quranService` and `_isAppInitiatedStop`
/// is irrelevant here — the Quran player has its own lifecycle inside
/// [QuranAudioService].
mixin AudioServiceQuranMixin {
  QuranAudioService get quranService;

  int get quranSurahIndex => quranService.quranSurahIndex;

  Future<void> playQuranFromServer(String serverUrl) =>
      quranService.playQuranFromServer(serverUrl);

  Future<void> playQuranSurah(String serverUrl, int surahNumber) =>
      quranService.playSurah(serverUrl, surahNumber);

  int? get currentQuranSurah => quranService.currentSurahNumber;

  Stream<int> get onQuranSurahCompleted => quranService.onSurahCompleted;

  void setQuranNextSurahResolver(NextSurahResolver? resolver) =>
      quranService.setNextSurahResolver(resolver);

  Future<void> pauseQuranPlayer() => quranService.pauseQuranPlayer();

  Future<void> resumeOrRestartQuranPlayer(String serverUrl) =>
      quranService.resumeOrRestartQuranPlayer(serverUrl);

  Future<void> restartQuranCurrentSurah(String serverUrl) =>
      quranService.restartQuranCurrentSurah(serverUrl);

  Future<void> resumeQuranPlayer() => quranService.resumeQuranPlayer();

  Future<void> stopQuranPlayer() => quranService.stopQuranPlayer();
}
