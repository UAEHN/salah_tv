/// One entry in the remote-config reciter catalogue.
/// Wired into the audio layer by [id]; never matched by [name] or [url].
class TakbeeratReciter {
  const TakbeeratReciter({
    required this.id,
    required this.name,
    required this.url,
  });

  /// Stable identifier — must stay unique across the catalogue and survive
  /// renames so persisted user preferences keep resolving.
  final String id;

  /// Arabic display name shown in the reciter picker.
  final String name;

  /// HTTPS mp3 URL — streamed by the audio port, never bundled.
  final String url;
}
