import '../../domain/entities/widget_payload.dart';

/// Flattens [WidgetPayload] into the SharedPreferences-shaped key/value maps
/// consumed by the native widget. Strings and Longs are kept in separate maps
/// because the home_widget plugin types them distinctly.
class WidgetPayloadFlat {
  final Map<String, String> strings;
  final Map<String, int> longs;
  const WidgetPayloadFlat(this.strings, this.longs);
}

WidgetPayloadFlat flattenWidgetPayload(WidgetPayload p) {
  final strings = <String, String>{
    'city': p.cityLabel,
    'hijri': p.hijriLabel,
    'gradient': p.gradientKey,
    'remaining_hm': p.remainingTemplateHm,
    'remaining_h': p.remainingTemplateH,
    'remaining_m': p.remainingTemplateM,
    'remaining_now': p.remainingNowLabel,
    'slots_count': p.slots.length.toString(),
  };
  final longs = <String, int>{};
  for (var i = 0; i < p.slots.length; i++) {
    final s = p.slots[i];
    strings['slot_${i}_key'] = s.key;
    strings['slot_${i}_label'] = s.label;
    strings['slot_${i}_time'] = s.timeLabel;
    longs['slot_${i}_ts'] = s.timestampMillis;
  }
  return WidgetPayloadFlat(strings, longs);
}
