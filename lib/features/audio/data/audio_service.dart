import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/adhan_sounds.dart';
import '../domain/i_audio_repository.dart';
import '../../prayer/domain/i_prayer_audio_port.dart';
import 'announcement_service.dart';
import 'quran_audio_service.dart';

class AudioService implements IAudioRepository, IPrayerAudioPort {
  // Issue 4/5: custom broadcast stream so we can fire it from both natural
  // completion AND external interruption (audio focus loss).
  final StreamController<void> _onCompleteController =
      StreamController<void>.broadcast();

  // Issue 5: set true around any app-initiated _player.stop() so the
  // onPlayerStateChanged listener can distinguish intentional stops from
  // external interruptions (audio focus lost, another app takes over).
  bool _isAppInitiatedStop = false;

  AudioService() {
    // Natural completion → advance state machine
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _onCompleteController.add(null);
    });

    // Issue 5: external interruption detection.
    // If the player reaches PlayerState.stopped while _isPlaying is true and
    // the app did NOT initiate the stop, treat it as a completion so the state
    // machine advances immediately instead of freezing for 4 minutes.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped &&
          _isPlaying &&
          !_isAppInitiatedStop) {
        _isPlaying = false;
        _onCompleteController.add(null);
      }
    });
  }

  // ── Adhan / Dua / Iqama player ──────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<void> get onComplete => _onCompleteController.stream;

  // Issue 3: return bool so the caller can detect a silent audio failure and
  // recover immediately rather than waiting for the 4-minute fallback timer.

  @override
  Future<bool> playAdhan({String soundKey = 'default'}) async {
    try {
      _isAppInitiatedStop = true;
      await _player.stop();
      _isAppInitiatedStop = false;
      _isPlaying = true;
      final asset = kAdhanSounds
              .firstWhere(
                (s) => s.key == soundKey,
                orElse: () => kAdhanSounds.first,
              )
              .asset;
      await _player.play(AssetSource(asset));
      return true;
    } catch (_) {
      _isPlaying = false;
      _isAppInitiatedStop = false;
      return false;
    }
  }

  @override
  Future<bool> playDua() async {
    try {
      _isAppInitiatedStop = true;
      await _player.stop();
      _isAppInitiatedStop = false;
      _isPlaying = true;
      await _player.play(AssetSource('audio/dua.mp3'));
      return true;
    } catch (_) {
      _isPlaying = false;
      _isAppInitiatedStop = false;
      return false;
    }
  }

  @override
  Future<bool> playIqama() async {
    try {
      _isAppInitiatedStop = true;
      await _player.stop();
      _isAppInitiatedStop = false;
      _isPlaying = true;
      await _player.play(AssetSource('audio/iqama.mp3'));
      return true;
    } catch (_) {
      _isPlaying = false;
      _isAppInitiatedStop = false;
      return false;
    }
  }

  @override
  Future<void> stop() async {
    _isAppInitiatedStop = true;
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
    _isAppInitiatedStop = false;
  }

  // ── Pre-alert bell (separate player, fire-and-forget) ────────────────────
  final AudioPlayer _bellPlayer = AudioPlayer();

  // ── Prayer announcement (separate player, awaited before adhan) ──────────
  final AnnouncementService _announcement = AnnouncementService();

  @override
  Future<void> playPrayerAnnouncement(String prayerKey) =>
      _announcement.play(prayerKey);

  @override
  Future<void> playPreAlertBell() async {
    try {
      await _bellPlayer.setVolume(0.15);
      await _bellPlayer.play(AssetSource('audio/bell.wav'));
    } catch (_) {}
  }

  // ── Quran background player (delegated to QuranAudioService) ─────────────
  final QuranAudioService _quranService = QuranAudioService();

  @override
  int get quranSurahIndex => _quranService.quranSurahIndex;

  @override
  Future<void> playQuranFromServer(String serverUrl) =>
      _quranService.playQuranFromServer(serverUrl);

  @override
  Future<void> pauseQuranPlayer() => _quranService.pauseQuranPlayer();

  @override
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) =>
      _quranService.resumeOrRestartQuranPlayer(serverUrl);

  @override
  Future<void> restartQuranCurrentSurah(String serverUrl) =>
      _quranService.restartQuranCurrentSurah(serverUrl);

  @override
  Future<void> resumeQuranPlayer() => _quranService.resumeQuranPlayer();

  @override
  Future<void> stopQuranPlayer() => _quranService.stopQuranPlayer();

  @override
  void dispose() {
    _onCompleteController.close();
    _player.dispose();
    _bellPlayer.dispose();
    _announcement.dispose();
    _quranService.dispose();
  }
}
