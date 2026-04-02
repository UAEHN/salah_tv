class FeedbackEntry {
  final String type; // 'bug' | 'suggestion' | 'other'
  final String message;
  final String platform;
  final DateTime createdAt;

  const FeedbackEntry({
    required this.type,
    required this.message,
    required this.platform,
    required this.createdAt,
  });
}
