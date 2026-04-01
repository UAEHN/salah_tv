/// A single remembrance (dhikr) item.
class Dhikr {
  final String text;
  final String source;
  final int count;
  final String? audioUrl;

  const Dhikr({
    required this.text,
    required this.source,
    this.count = 1,
    this.audioUrl,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
        text: json['text'] as String,
        source: 'Hisn Al-Muslim',
        count: json['count'] as int? ?? 1,
        audioUrl: json['audioUrl'] as String?,
      );
}
