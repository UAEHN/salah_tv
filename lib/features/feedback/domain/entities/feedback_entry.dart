class FeedbackEntry {
  final String type; // 'bug' | 'suggestion' | 'other'
  final String message;
  final String platform;
  final String? contact;
  final Map<String, String> diagnostics;
  final DateTime createdAt;

  /// Stable per-install identifier (same value as `device_heartbeats/{id}`
  /// and `push_profiles/{id}`). Lets the dashboard join feedback to crashes
  /// and heartbeats from the same device. Nullable for back-compat with
  /// older entries / call sites that don't pass it.
  final String? deviceId;

  const FeedbackEntry({
    required this.type,
    required this.message,
    required this.platform,
    required this.createdAt,
    this.contact,
    this.diagnostics = const {},
    this.deviceId,
  });
}
