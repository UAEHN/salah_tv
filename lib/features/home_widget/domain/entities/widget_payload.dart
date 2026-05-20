import 'widget_prayer_slot.dart';

/// Snapshot published to the native widget. Native computes "next prayer" and
/// "remaining" from [slots] timestamps; Flutter only supplies pre-localized
/// strings and the templates used for the remaining-time text.
class WidgetPayload {
  final List<WidgetPrayerSlot> slots;
  final String cityLabel;
  final String hijriLabel;
  final String gradientKey;
  final String remainingTemplateHm;
  final String remainingTemplateH;
  final String remainingTemplateM;
  final String remainingNowLabel;

  WidgetPayload({
    required List<WidgetPrayerSlot> slots,
    required this.cityLabel,
    required this.hijriLabel,
    required this.gradientKey,
    required this.remainingTemplateHm,
    required this.remainingTemplateH,
    required this.remainingTemplateM,
    required this.remainingNowLabel,
  }) : slots = List.unmodifiable(slots);
}
