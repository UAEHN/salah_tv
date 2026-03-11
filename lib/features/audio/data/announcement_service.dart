import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Plays a short prayer-name announcement on an isolated [AudioPlayer].
/// Completely separate from [AudioService._player] so the state-machine
/// [onComplete] stream is never triggered by the announcement finishing.
class AnnouncementService {
  static const _assets = {
    'fajr': 'audio/Fajr.mp3',
    'dhuhr': 'audio/Dhuhr.mp3',
    'asr': 'audio/Asr.mp3',
    'maghrib': 'audio/Maghrib.mp3',
    'isha': 'audio/Isha.mp3',
  };

  final AudioPlayer _player = AudioPlayer();

  /// Plays the announcement for [prayerKey] and returns the instant it ends.
  /// [sub.cancel] is fire-and-forget so there is zero latency before adhan.
  Future<void> play(String prayerKey) async {
    final asset = _assets[prayerKey];
    if (asset == null) return;
    try {
      final completer = Completer<void>();
      final sub = _player.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) completer.complete();
      });
      await _player.play(AssetSource(asset));
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
      sub.cancel();
    } catch (_) {}
  }

  void dispose() => _player.dispose();
}
