import 'dart:async';
import '../../prayer/domain/i_prayer_audio_port.dart';

/// Mobile-only no-op implementation of [IPrayerAudioPort].
/// Prayer-cycle audio (adhan, dua, iqama) is suppressed on mobile because
/// notifications carry the sound. The cycle still runs normally:
/// each play method returns true and fires [onComplete] after one event-loop
/// tick so the engine's subscription drives stopAdhan → triggerDua → stopDua
/// → iqama countdown → stopIqama exactly as on TV, just silently.
class NoOpPrayerAudioPort implements IPrayerAudioPort {
  final _ctrl = StreamController<void>.broadcast();

  @override
  Stream<void> get onComplete => _ctrl.stream;

  void _fireComplete() => Future.delayed(Duration.zero, () => _ctrl.add(null));

  @override
  Future<bool> playAdhan({String soundKey = 'default'}) async {
    _fireComplete();
    return true;
  }

  @override
  Future<bool> playDua() async {
    _fireComplete();
    return true;
  }

  @override
  Future<bool> playIqama() async {
    _fireComplete();
    return true;
  }

  @override
  Future<void> playPreAlertBell() async {}

  @override
  Future<void> playPrayerAnnouncement(String prayerKey) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> playQuranFromServer(String serverUrl) async {}

  @override
  Future<void> pauseQuranPlayer() async {}

  @override
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) async {}

  @override
  Future<void> restartQuranCurrentSurah(String serverUrl) async {}

  @override
  Future<void> stopQuranPlayer() async {}
}
