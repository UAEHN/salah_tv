import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/diagnostics/diagnostic_level.dart' as diag;
import '../../../core/adhan_sounds.dart';
import '../../settings/domain/entities/custom_adhan.dart';
import '../../settings/domain/i_custom_adhan_repository.dart';
import '../domain/i_audio_repository.dart';
import '../../prayer/domain/i_prayer_audio_port.dart';
import '../../prayer/domain/entities/audio_output_state.dart';
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
  final AppDiagnostics? _diagnostics;

  AudioService({
    ICustomAdhanRepository? customAdhans,
    AppDiagnostics? diagnostics,
  }) : _customAdhans = customAdhans,
       _diagnostics = diagnostics {
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _diag(diag.DiagnosticLevel.info, 'audio_player_completed');
      _onCompleteController.add(null);
    });
    // Issue 5: external interruption detection. If the player reaches
    // PlayerState.stopped while _isPlaying is true and the app did NOT
    // initiate the stop, treat it as a completion so the state machine
    // advances immediately instead of freezing for 4 minutes.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && _isPlaying && !_isAppInitiatedStop) {
        _isPlaying = false;
        _diag(diag.DiagnosticLevel.warning, 'audio_player_external_stop');
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
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        _diag(
          diag.DiagnosticLevel.info,
          'audio_play_attempt',
          fields: {'label': label, 'attempt': attempt},
        );
        _isAppInitiatedStop = true;
        await _player.stop();
        _isAppInitiatedStop = false;
        // ReleaseMode.release frees decoder/buffer resources between prayers.
        await _player.setReleaseMode(ReleaseMode.release);
        _isPlaying = true;
        final source = await resolveSource();
        await _ensureMediaAudible(label);
        await _player.play(source, volume: 1.0, mode: PlayerMode.mediaPlayer);
        _diag(
          diag.DiagnosticLevel.info,
          'audio_play_started',
          fields: {
            'label': label,
            'attempt': attempt,
            'source_type': source.runtimeType.toString(),
          },
        );
        return true;
      } catch (e) {
        debugPrint('[Audio] $label attempt $attempt failed: $e');
        _diag(
          attempt == 1
              ? diag.DiagnosticLevel.warning
              : diag.DiagnosticLevel.error,
          attempt == 1 ? 'audio_play_retry' : 'audio_play_failed',
          fields: {
            'label': label,
            'attempt': attempt,
            'error_type': e.runtimeType.toString(),
          },
          error: e,
          forceUpload: attempt == 2,
        );
        _isPlaying = false;
        _isAppInitiatedStop = false;
        if (attempt == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }
    }
    return false;
  }

  @override
  Future<bool> playAdhan({String soundKey = 'default'}) async {
    final success = await _playMain(
      () => _resolveAdhanSource(soundKey),
      'playAdhan',
    );
    if (success || soundKey == 'default') return success;
    _diag(
      diag.DiagnosticLevel.warning,
      'adhan_audio_fallback_to_default',
      fields: {'failed_sound_key': soundKey},
      forceUpload: true,
    );
    return _playMain(
      () async => AssetSource('audio/adhan.mp3'),
      'playAdhanFallback',
    );
  }

  // Same channel PlatformConfig uses; AudioService keeps its own reference so
  // it stays decoupled from startup wiring.
  static const _platform = MethodChannel('ghasaq/platform');

  Future<void> _ensureMediaAudible(String label) async {
    try {
      final map = await _platform.invokeMapMethod<String, dynamic>(
        'ensureMediaAudible',
      );
      if (map == null) return;
      final before = (map['beforeVolume'] as int?) ?? -1;
      final after = (map['afterVolume'] as int?) ?? -1;
      final wasMuted = (map['wasMuted'] as bool?) ?? false;
      if (wasMuted || before <= 0) {
        _diag(
          diag.DiagnosticLevel.warning,
          'audio_volume_auto_raised',
          fields: {
            'label': label,
            'before_volume': before,
            'after_volume': after,
            'max_volume': (map['maxVolume'] as int?) ?? -1,
          },
          forceUpload: true,
        );
      }
    } on MissingPluginException {
      _diag(diag.DiagnosticLevel.warning, 'audio_volume_guard_missing_plugin');
    } on PlatformException catch (e) {
      _diag(
        diag.DiagnosticLevel.warning,
        'audio_volume_guard_failed',
        fields: {'label': label, 'code': e.code, 'message': e.message},
      );
    }
  }

  @override
  Future<AudioOutputState?> readAudioOutputState() async {
    try {
      final map = await _platform.invokeMapMethod<String, dynamic>(
        'getAudioState',
      );
      if (map == null) return null;
      return AudioOutputState(
        volume: (map['volume'] as int?) ?? 0,
        maxVolume: (map['maxVolume'] as int?) ?? 0,
        muted: (map['muted'] as bool?) ?? false,
      );
    } on MissingPluginException {
      _diag(diag.DiagnosticLevel.warning, 'audio_state_missing_plugin');
      return null; // older build without the native handler
    } on PlatformException catch (e) {
      _diag(
        diag.DiagnosticLevel.warning,
        'audio_state_platform_error',
        fields: {'code': e.code, 'message': e.message},
      );
      return null;
    }
  }

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
      if (path != null) {
        _diag(
          diag.DiagnosticLevel.info,
          'audio_source_resolved',
          fields: {'sound_key': soundKey, 'source': 'custom_file'},
        );
        return DeviceFileSource(path);
      }
      _diag(
        diag.DiagnosticLevel.error,
        'custom_audio_source_missing',
        fields: {'sound_key': soundKey, 'file_name': fileName},
        forceUpload: true,
      );
    }
    final asset = kAdhanSounds
        .firstWhere((s) => s.key == soundKey, orElse: () => kAdhanSounds.first)
        .asset;
    _diag(
      diag.DiagnosticLevel.info,
      'audio_source_resolved',
      fields: {'sound_key': soundKey, 'source': 'asset', 'asset': asset},
    );
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
      _diag(
        diag.DiagnosticLevel.error,
        'audio_stop_failed',
        fields: {'error_type': e.runtimeType.toString()},
        error: e,
        forceUpload: true,
      );
    }
    _isAppInitiatedStop = false;
  }

  void _diag(
    diag.DiagnosticLevel level,
    String name, {
    Map<String, Object?> fields = const {},
    Object? error,
    bool forceUpload = false,
  }) {
    unawaited(
      _diagnostics?.record(
            level,
            name,
            fields: fields,
            error: error,
            forceUpload: forceUpload,
          ) ??
          Future<void>.value(),
    );
  }

  @override
  Future<void> playPrayerAnnouncement(String key) => _announcement.play(key);

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
