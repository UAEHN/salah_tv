import '../../../prayer/data/adhan_calculation_source.dart';
import '../../../prayer/domain/entities/daily_prayer_times.dart';

/// Computes a single day's prayer times for a candidate method so the
/// picker can show a side-by-side preview before the user commits.
///
/// Returns `null` when the calculation fails or yields a non-monotonic
/// result (which can happen near the poles in mid-summer) — callers
/// render an empty dash in that case rather than misleading numbers.
DailyPrayerTimes? computePreviewForMethod({
  required double latitude,
  required double longitude,
  required String methodKey,
  required String highLatitudeRuleKey,
  DateTime? date,
}) {
  try {
    final t = AdhanCalculationSource().calculateForDate(
      latitude,
      longitude,
      date ?? DateTime.now(),
      methodKey,
      highLatitudeRuleKey: highLatitudeRuleKey,
    );
    return AdhanCalculationSource.isValid(t) ? t : null;
  } catch (_) {
    return null;
  }
}

/// Returns the [DateTime] for [prayerKey] off a computed result, or
/// `dhuhr` for unknown keys (cheap defensive fallback).
DateTime previewTimeOf(DailyPrayerTimes t, String prayerKey) =>
    switch (prayerKey) {
      'fajr' => t.fajr,
      'dhuhr' => t.dhuhr,
      'asr' => t.asr,
      'maghrib' => t.maghrib,
      'isha' => t.isha,
      _ => t.dhuhr,
    };
