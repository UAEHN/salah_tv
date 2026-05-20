import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../../../core/adhan_sounds.dart';
import '../../settings/domain/entities/custom_adhan.dart';
import '../../settings/domain/i_custom_adhan_repository.dart';
import '../domain/i_audio_repository.dart';
import '../../prayer/domain/i_prayer_audio_port.dart';
import 'announcement_service.dart';
import 'audio_service_quran_mixin.dart';
import 'bell_player.dart';
import 'quran_audio_service.dart';

class AudioService
    with AudioServiceQuranMixin
    implements IAudioRepository, IPrayerAudioPort {
  /// Optional — only registered on mobile. On TV stays null and `custom:*`
  /// keys fall back to the default bundled sound.
  final ICustomAdhanRepository? _customAdhans;

  // Issue 4/5: broadcast stream fired from natural completion AND external
  // interruption (audio focus loss).
  final StreamController<void> _onCompleteController =
      StreamController<void>.broadcast();

  // Issue 5: true around any app-initiated _player.stop() so the
  // onPlayerStateChanged listener can distinguish intentional stops from
  // external interruptions (audio focus lost, another app takes over).
  bool _isAppInitiatedStop = false;

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  final BellPlayer _bell = BellPlayer();
  final AnnouncementService _announcement = AnnouncementService();
  final QuranAudioService _quranService = QuranAudioService();

  AudioService({ICustomAdhanRepository? customAdhans})
      : _customAdhans = customAdhans {
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _onCompleteController.add(null);
    });
    // Issue 5: external interruption detection. If the player reaches
    // PlayerState.stopped while _isPlaying is true and the app did NOT
    // initiate the stop, treat it as a completion so the state machine
    // advances immediately instead of freezing for 4 minutes.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped &&
          _isPlaying &&
          !_isAppInitiatedStop) {
        _isPlaying = false;
        _onCompleteController.add(null);
      }
    });
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<void> get onComplete => _onCompleteController.stream;

  @override
  QuranAudioService get quranService => _quranService;

  /// Issue 3/5: shared play pipeline used by adhan/dua/iqama. Brackets the
  /// preceding stop() with `_isAppInitiatedStop` so the external-interruption
  /// listener does not misfire, releases ExoPlayer resources, and returns
  /// false on failure so the engine falls back immediately.
  Future<bool> _playMain(
    Future<Source> Function() resolveSource,
    String label,
  ) async {
    try {
      _isAppInitiatedStop = true;
      await _player.stop();
      _isAppInitiatedStop = false;
      // ReleaseMode.release frees decoder/buffer resources between prayers.
      await _player.setReleaseMode(ReleaseMode.release);
      _isPlaying = true;
      final source = await resolveSource();
      await _player.play(source);
      return true;
    } catch (e) {
      debugPrint('[Audio] $label failed: $e');
      _isPlaying = false;
      _isAppInitiatedStop = false;
      return false;
    }
  }

  @override
  Future<bool> playAdhan({String soundKey = 'default'}) =>
      _playMain(() => _resolveAdhanSource(soundKey), 'playAdhan');

  @override
  Future<bool> playDua() =>
      _playMain(() async => AssetSource('audio/dua.mp3'), 'playDua');

  @override
  Future<bool> playIqama() =>
      _playMain(() async => AssetSource('audio/iqama.mp3'), 'playIqama');

  Future<Source> _resolveAdhanSource(String soundKey) async {
    final fileName = CustomAdhan.extractFileName(soundKey);
    final repo = _customAdhans;
    if (fileName != null && repo != null) {
      final result = await repo.absolutePathOf(fileName);
      final path = result.fold((_) => null, (p) => p);
      if (path != null) return DeviceFileSource(path);
    }
    final asset = kAdhanSounds
        .firstWhere((s) => s.key == soundKey, orElse: () => kAdhanSounds.first)
        .asset;
    return AssetSource(asset);
  }

  @override
  Future<void> stop() async {
    _isAppInitiatedStop = true;
    try {
      await _player.stop();
      _isPlaying = false;
      await _player.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('[Audio] stop failed: $e');
    }
    _isAppInitiatedStop = false;
  }

  @override
  Future<void> playPrayerAnnouncement(String prayerKey) =>
      _announcement.play(prayerKey);

  @override
  Future<void> playPreAlertBell() => _bell.play();

  @override
  void dispose() {
    _onCompleteController.close();
    _player.dispose();
    _bell.dispose();
    _announcement.dispose();
    _quranService.dispose();
  }
}
