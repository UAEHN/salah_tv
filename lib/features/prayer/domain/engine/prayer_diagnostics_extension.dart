import 'dart:async';

import '../../../../core/diagnostics/diagnostic_level.dart';
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';

extension PrayerDiagnostics on PrayerCycleBase {
  void clearPrayerAlertError() {
    s.lastPrayerAlertError = null;
    s.prayerAlertErrorAt = null;
  }

  void markPrayerAlertError({
    required String alertType,
    required String prayerKey,
    required String code,
    String? detail,
  }) {
    final cleanDetail = detail != null && detail.isNotEmpty ? detail : null;
    final messageParts = <String>[
      'تعذر تشغيل ${alertType == 'iqama' ? 'الإقامة' : 'الأذان'}',
      'code=$code',
      'prayer=$prayerKey',
    ];
    if (cleanDetail != null) {
      messageParts.add(cleanDetail);
    }
    final message = messageParts.join(' | ');
    s.lastPrayerAlertError = message;
    s.prayerAlertErrorAt = s.now;
    final fields = <String, Object?>{
      'alert_type': alertType,
      'prayer_key': prayerKey,
      'code': code,
    };
    if (cleanDetail != null) {
      fields['detail'] = cleanDetail;
    }
    diag(
      DiagnosticLevel.error,
      'prayer_alert_user_visible_error',
      fields: fields,
      forceUpload: true,
    );
    notify();
  }

  void diag(
    DiagnosticLevel level,
    String name, {
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stack,
    bool forceUpload = false,
  }) {
    final phase = activeCyclePhase(s);
    unawaited(
      diagnostics?.record(
            level,
            name,
            fields: {
              'phase': phase,
              'prayer_key': s.activeCyclePrayerKey,
              'current_adhan': s.currentAdhanPrayerKey,
              'iqama_prayer': s.iqamaPrayerKey,
              'next_prayer': s.nextPrayerKey,
              'countdown_sec': s.countdown.inSeconds,
              'city': settings.selectedCity,
              'country': settings.selectedCountry,
              'adhan_mode': settings.adhanMode.name,
              'iqama_mode': settings.iqamaMode.name,
              'mosque_mode': settings.isMosqueMode,
              'adhan_sound': settings.adhanSound,
              'iqama_delay_min': s.currentIqamaDelayMin,
              ...fields,
            },
            error: error,
            stack: stack,
            forceUpload: forceUpload,
          ) ??
          Future<void>.value(),
    );
  }
}
