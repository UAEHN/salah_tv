/// One prayer time slot published to the native widget. The native side picks
/// the first slot whose [timestampMillis] is in the future as "next".
class WidgetPrayerSlot {
  final String key;
  final String label;
  final String timeLabel;
  final int timestampMillis;

  const WidgetPrayerSlot({
    required this.key,
    required this.label,
    required this.timeLabel,
    required this.timestampMillis,
  });
}
