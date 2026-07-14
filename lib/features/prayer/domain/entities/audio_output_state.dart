/// Snapshot of the device's media-output state at a moment in time, read from
/// the native side. Lets the engine detect the "adhan played but nobody heard
/// it" case (TV muted / volume at zero) that `playAdhan` returning `true`
/// cannot reveal on its own.
class AudioOutputState {
  /// Current media-stream volume (0..[maxVolume]).
  final int volume;

  /// Maximum media-stream volume for the device.
  final int maxVolume;

  /// True when the media stream is explicitly muted.
  final bool muted;

  /// Active audio output route (e.g. `speaker`, `hdmi`, `bt_a2dp`, or `none`
  /// when there is no output device at all). Diagnostic only — surfaces an
  /// adhan routed to a dead/absent output that volume alone reads as audible.
  final String route;

  /// Whether the OS reports media audio actively playing at probe time.
  final bool musicActive;

  const AudioOutputState({
    required this.volume,
    required this.maxVolume,
    required this.muted,
    this.route = '',
    this.musicActive = false,
  });

  /// True when the adhan would play but produce no audible sound.
  bool get isInaudible => muted || volume <= 0;
}
