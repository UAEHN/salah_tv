import '../../../settings/domain/entities/app_settings.dart';

/// Builds the diagnostic block that gets pre-filled in outgoing email or
/// copied to clipboard before opening Telegram. Mirrors the data the
/// in-app form already attaches automatically — versioning, device,
/// location, prayer settings — organised into readable sections.
String buildFeedbackContactMessage({
  required Map<String, String> diagnostics,
  required AppSettings settings,
  required String userPrompt,
}) {
  final buffer = StringBuffer();

  _section(buffer, '📱 الجهاز والتطبيق', [
    'الإصدار: ${diagnostics['appVersion'] ?? '-'}',
    'الجهاز: ${diagnostics['deviceType'] == 'tv' ? 'تلفاز' : 'هاتف'} '
            '— ${diagnostics['os'] ?? '-'} ${diagnostics['osVersion'] ?? ''}'
        .trim(),
    'لغة التطبيق: ${settings.locale}',
    'لغة النظام: ${diagnostics['deviceLocale'] ?? '-'}',
    'الوقت المحلي: ${diagnostics['deviceLocalTime'] ?? '-'}',
    'منطقة الجهاز الزمنية: ${diagnostics['deviceTimezone'] ?? '-'}',
  ]);

  _section(buffer, '📍 الموقع', [
    'المدينة: ${settings.selectedCity} — ${settings.selectedCountry}',
    'مصدر الموقع: ${settings.isCalculatedLocation ? 'محسوب من GPS' : 'من قاعدة بيانات التطبيق'}',
    if (settings.selectedLatitude != null && settings.selectedLongitude != null)
      'الإحداثيات: ${settings.selectedLatitude!.toStringAsFixed(4)}, '
          '${settings.selectedLongitude!.toStringAsFixed(4)}',
    if (settings.selectedTimeZoneId != null)
      'منطقة المدينة الزمنية: ${settings.selectedTimeZoneId}',
    if (settings.utcOffsetHours != null)
      'إزاحة UTC: ${_formatOffset(settings.utcOffsetHours!)}',
  ]);

  // Prayer settings (calculation method, madhab, …) only matter when the
  // app actually computes prayer times — i.e. for GPS-calculated locations.
  // For DB-backed cities the times come from the bundled SQLite, so these
  // settings have no effect and would just be noise in the diagnostic.
  if (settings.isCalculatedLocation) {
    _section(buffer, '🕌 إعدادات الصلاة', [
      'طريقة الحساب: ${settings.calculationMethod}',
      'المذهب: ${settings.madhab}',
      'نمط الأذان: ${settings.adhanMode.name}',
      'نمط الإقامة: ${settings.iqamaMode.name}',
      'وضع المسجد: ${_yesNo(settings.isMosqueMode)}',
      'صوت الأذان: ${settings.adhanSound}',
      if (settings.customAdhans.isNotEmpty)
        'أصوات أذان مخصّصة: ${settings.customAdhans.length}',
    ]);
  }

  buffer
    ..writeln()
    ..writeln(userPrompt);
  return buffer.toString();
}

void _section(StringBuffer b, String title, List<String> lines) {
  b
    ..writeln('─────────────────────────────')
    ..writeln(title);
  for (final l in lines) {
    b.writeln(l);
  }
}

String _yesNo(bool v) => v ? 'مفعّل' : 'معطّل';

String _formatOffset(double hours) {
  final sign = hours >= 0 ? '+' : '-';
  final abs = hours.abs();
  final h = abs.floor();
  final m = ((abs - h) * 60).round();
  return 'UTC $sign${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}';
}

/// Builds a `mailto:` URI string with subject + body URL-encoded so the
/// user's mail app opens with everything pre-filled.
///
/// Uses [Uri.encodeComponent] (not `encodeQueryComponent`): mailto: URIs
/// follow RFC 6068 which expects spaces as `%20`, while `encodeQueryComponent`
/// emits `+` per the HTML form spec — and Gmail/Outlook render that `+`
/// literally rather than as a space.
String buildMailtoUri({
  required String email,
  required String subject,
  required String body,
}) {
  return 'mailto:$email'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}';
}
