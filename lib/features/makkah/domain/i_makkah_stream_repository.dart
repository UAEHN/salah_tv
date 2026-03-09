abstract class IMakkahStreamRepository {
  /// Returns an HLS stream URL for the given YouTube video ID,
  /// or null if extraction fails (stream offline, network error, etc.).
  Future<String?> extractStreamUrl(String videoId);

  void dispose();
}
