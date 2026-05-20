class FeedbackEntry {
  final String type; // 'bug' | 'suggestion' | 'other'
  final String message;
  final String platform;
  final String? contact;
  final Map<String, String> diagnostics;
  final DateTime createdAt;

  const FeedbackEntry({
    required this.type,
    required this.message,
    required this.platform,
    required this.createdAt,
    this.contact,
    this.diagnostics = const {},
  });
}
