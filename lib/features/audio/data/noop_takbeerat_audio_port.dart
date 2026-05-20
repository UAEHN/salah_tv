import '../../prayer/domain/i_takbeerat_audio_port.dart';

/// Mobile-only no-op. Takbeerat audio is a TV-side feature (always-on,
/// landscape, in-app cycle); on mobile the cycle engine still needs a port
/// to call into so we register this silent shim.
class NoOpTakbeeratAudioPort implements ITakbeeratAudioPort {
  @override
  bool get isPlaying => false;

  @override
  Future<void> play(String url) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}
}
