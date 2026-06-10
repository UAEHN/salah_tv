import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../../core/app_config.dart';
import '../domain/i_ayah_audio_cache.dart';
import '../domain/i_ayah_audio_port.dart';

/// Per-ayah audio player using its own [AudioPlayer] instance so completion
/// events never reach the prayer cycle engine or the adhkar player.
/// Mirrors the isolation pattern of `AdhkarAudioService`.
///
/// Downloads each ayah once via [IAyahAudioCache] then plays the local
/// file on every subsequent tap so re-listens work offline and consume
/// no extra bandwidth.
class AyahAudioService implements IAyahAudioPort {
  final IAyahAudioCache _cache;
  final AudioPlayer _player = AudioPlayer();
  final StreamController<AyahPlaybackEvent> _events =
      StreamController<AyahPlaybackEvent>.broadcast();

  int? _currentSurah;
  int? _currentAyah;
  bool _isPlaying = false;
  bool _appInitiatedStop = false;

  AyahAudioService(this._cache) {
    _player.onPlayerComplete.listen((_) => _emitCompleted());
    // Android may emit `stopped` instead of `completed` when the file ends
    // naturally — same guard as AdhkarAudioService to avoid double events.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && _isPlaying && !_appInitiatedStop) {
        _emitCompleted();
      }
    });
  }

  void _emitCompleted() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _events.add(
      AyahPlaybackEvent(
        AyahAudioStatus.completed,
        surahNumber: _currentSurah,
        ayahNumber: _currentAyah,
      ),
    );
  }

  @override
  Stream<AyahPlaybackEvent> get events => _events.stream;

  @override
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String reciterUrlSegment,
  }) async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _appInitiatedStop = false;
      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;
      _events.add(
        AyahPlaybackEvent(
          AyahAudioStatus.loading,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        ),
      );
      final url = AppConfig.ayahAudioUrl(
        surah: surahNumber,
        ayah: ayahNumber,
        reciterUrlSegment: reciterUrlSegment,
      );
      final localPath = await _cache.getOrDownload(
        reciterId: reciterUrlSegment,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        url: url,
      );
      _isPlaying = true;
      if (localPath != null) {
        await _player.play(DeviceFileSource(localPath));
      } else {
        // Cache failed — fall back to streaming so the user still hears
        // the ayah (just no offline benefit for this tap).
        await _player.play(UrlSource(url));
      }
      _events.add(
        AyahPlaybackEvent(
          AyahAudioStatus.playing,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        ),
      );
    } catch (e) {
      _appInitiatedStop = false;
      _isPlaying = false;
      debugPrint('[AyahAudio] play failed: $e');
      _events.add(
        AyahPlaybackEvent(
          AyahAudioStatus.error,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        ),
      );
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
      _events.add(
        AyahPlaybackEvent(
          AyahAudioStatus.paused,
          surahNumber: _currentSurah,
          ayahNumber: _currentAyah,
        ),
      );
    } catch (e) {
      debugPrint('[AyahAudio] pause failed: $e');
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _player.resume();
      _events.add(
        AyahPlaybackEvent(
          AyahAudioStatus.playing,
          surahNumber: _currentSurah,
          ayahNumber: _currentAyah,
        ),
      );
    } catch (e) {
      debugPrint('[AyahAudio] resume failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _isPlaying = false;
      _appInitiatedStop = false;
      _events.add(const AyahPlaybackEvent(AyahAudioStatus.idle));
    } catch (e) {
      _appInitiatedStop = false;
      debugPrint('[AyahAudio] stop failed: $e');
    }
  }

  void dispose() {
    _events.close();
    _player.dispose();
  }
}
