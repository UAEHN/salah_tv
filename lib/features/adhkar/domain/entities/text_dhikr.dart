/// A single text-based dhikr for the mobile reader feature.
/// Separate from [Dhikr] which is used by the TV audio feature.
class TextDhikr {
  final int id;
  final String categoryId;
  final String text;
  final int count;
  final String source;
  final String virtue;

  const TextDhikr({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.count,
    required this.source,
    this.virtue = '',
  });

  factory TextDhikr.fromJson(Map<String, dynamic> json) => TextDhikr(
    id: json['id'] as int,
    categoryId: json['categoryId'] as String,
    text: json['text'] as String,
    count: json['count'] as int? ?? 1,
    source: json['source'] as String? ?? '',
    virtue: json['virtue'] as String? ?? '',
  );
}
