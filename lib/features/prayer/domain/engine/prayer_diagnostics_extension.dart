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

  /// Unified "the adhan did NOT audibly sound for [prayerKey] today" signal.
  /// One event name so the Control Room shows every no-sound case in a single
  /// filter instead of three differently-named ones (overdue / recovery-skip /
  /// silent-rescue). [cause] tells them apart; [iqamaWillFire] flags the benign
  /// case where the prayer is still served (the mistimed call is suppressed but
  /// its iqama fires on time); [critical] escalates to FATAL for the worst case
  /// — a prayer that never fired while the user was watching. Always
  /// force-uploaded so a missed call is visible without waiting for the export.
  void diagAdhanNotSounded({
    required String prayerKey,
    required String cause,
    required bool iqamaWillFire,
    required int lateSeconds,
    bool critical = false,
  }) {
    diag(
      critical ? DiagnosticLevel.fatal : DiagnosticLevel.warning,
      'adhan_not_sounded',
      fields: {
        'missed_prayer': prayerKey,
        'cause': cause,
        'iqama_will_fire': iqamaWillFire,
        'is_foreground': s.isAppInForeground,
        'late_seconds': lateSeconds,
      },
      forceUpload: true,
    );
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
