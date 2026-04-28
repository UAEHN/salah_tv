/// Pure-Dart cancellation token — no Dio or Flutter dependencies.
/// Passed from the cubit through the use case to the data layer so
/// a city-switch mid-download aborts the HTTP request and the DB write.
class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() => _isCancelled = true;
}

/// Thrown by [PrayerCacheDbWriter] when [CancellationToken.isCancelled]
/// is detected mid-write. The SQLite transaction rolls back automatically.
class CancellationException implements Exception {
  const CancellationException();
}
