import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../../../core/adhan_sounds.dart';
import '../../settings/domain/entities/custom_adhan.dart';
import '../../settings/domain/i_custom_adhan_repository.dart';
import '../domain/i_audio_repository.dart';
import '../../prayer/domain/i_prayer_audio_port.dart';
import 'announcement_service.dart';
import 'quran_audio_service.dart';

class AudioService implements IAudioRepository, IPrayerAudioPort {
  /// Optional — only registered on mobile where the custom-adhan feature is
  /// exposed. On TV, stays null and `custom:*` keys fall back to the default
  /// bundled sound.
  final ICustomAdhanRepository? _customAdhans;

  // Issue 4/5: custom broadcast stream so we can fire it from both natural
  // completion AND external interruption (audio focus loss).
  final StreamController<void> _onCompleteController =
      StreamController<void>.broadcast();

  // Issue 5: set true around any app-initiated _player.stop() so the
  // onPlayerStateChanged listener can distinguish intentional stops from
  // external interruptions (audio focus lost, another app takes over).
  bool _isAppInitiatedStop = false;

  AudioService({ICustomAdhanRepository? customAdhans})
    : _customAdhans = customAdhans {
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
      // ReleaseMode.release tells ExoPlayer to free decoder/buffer resources
      // after each play. Without this the player holds native threads alive
      // between prayers (hours of idle), which causes mutex contention on the
      // platform channel and ANRs on TV boxes after ~2 hours.
      await _player.setReleaseMode(ReleaseMode.release);
      _isPlaying = true;
      final source = await _resolveAdhanSource(soundKey);
      await _player.play(source);
      return true;
    } catch (e) {
      debugPrint('[Audio] playAdhan failed: $e');
      _isPlaying = false;
      _isAppInitiatedStop = false;
      return false;
    }
  }

  Future<Source> _resolveAdhanSource(String soundKey) async {
    final fileName = CustomAdhan.extractFileName(soundKey);
    final repo = _customAdhans;
    if (fileName != null && repo != null) {
      final result = await repo.absolutePathOf(fileName);
      final path = result.fold((_) => null, (p) => p);
      if (path != null) return DeviceFileSource(path);
    }
    final asset = kAdhanSounds
        .firstWhere(
          (s) => s.key == soundKey,
          orElse: () => kAdhanSounds.first,
        )
        .asset;
    return AssetSource(asset);
  }

  @override
  Future<bool> playDua() async {
    try {
      _isAppInitiatedStop = true;
      await _player.stop();
      _isAppInitiatedStop = false;
      await _player.setReleaseMode(ReleaseMode.release);
      _isPlaying = true;
      await _player.play(AssetSource('audio/dua.mp3'));
      return true;
    } catch (e) {
      debugPrint('[Audio] playDua failed: $e');
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
      await _player.setReleaseMode(ReleaseMode.release);
      _isPlaying = true;
      await _player.play(AssetSource('audio/iqama.mp3'));
      return true;
    } catch (e) {
      debugPrint('[Audio] playIqama failed: $e');
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
      // Release native ExoPlayer resources so no threads idle between prayers.
      await _player.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('[Audio] stop failed: $e');
    }
    _isAppInitiatedStop = false;
  }

  // ── Pre-alert bell (separate player, fire-and-forget) ────────────────────
  // Lazy: only creates the ExoPlayer instance on first bell play.
  // An eagerly-created idle AudioPlayer keeps ExoPlayer native threads alive
  // for hours and contributes to the mutex contention seen in ANR traces.
  AudioPlayer? _bellPlayer;

  // ── Prayer announcement (separate player, awaited before adhan) ──────────
  final AnnouncementService _announcement = AnnouncementService();

  @override
  Future<void> playPrayerAnnouncement(String prayerKey) =>
      _announcement.play(prayerKey);

  @override
  Future<void> playPreAlertBell() async {
    try {
      _bellPlayer ??= AudioPlayer();
      await _bellPlayer!.setVolume(0.15);
      await _bellPlayer!.play(AssetSource('audio/bell.wav'));
    } catch (e) {
      debugPrint('[Audio] playPreAlertBell failed: $e');
    }
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
    _bellPlayer?.dispose();
    _announcement.dispose();
    _quranService.dispose();
  }
}
