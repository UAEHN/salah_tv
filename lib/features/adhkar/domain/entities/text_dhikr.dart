/// A single text-based dhikr for the mobile reader feature.
/// Separate from [Dhikr] which is used by the TV audio feature.
class TextDhikr {
  final int id;
  final String categoryId;
  final String text;
  final String transliteration;
  final int count;
  final String source;
  final String sourceEn;
  final String virtue;
  final String virtueEn;

  const TextDhikr({
    required this.id,
    required this.categoryId,
    required this.text,
    this.transliteration = '',
    required this.count,
    required this.source,
    this.sourceEn = '',
    this.virtue = '',
    this.virtueEn = '',
  });

  factory TextDhikr.fromJson(Map<String, dynamic> json) => TextDhikr(
    id: json['id'] as int,
    categoryId: json['categoryId'] as String,
    text: json['text'] as String,
    transliteration: json['transliteration'] as String? ?? '',
    count: json['count'] as int? ?? 1,
    source: json['source'] as String? ?? '',
    sourceEn: json['sourceEn'] as String? ?? '',
    virtue: json['virtue'] as String? ?? '',
    virtueEn: json['virtueEn'] as String? ?? '',
  );
}
