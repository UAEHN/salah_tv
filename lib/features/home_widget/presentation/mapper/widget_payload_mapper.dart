import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/city_translations.dart';
import '../../../../core/localization/date_localizer.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../prayer/domain/entities/daily_prayer_times.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/widget_payload.dart';
import '../../domain/entities/widget_prayer_slot.dart';

/// Builds a [WidgetPayload] from runtime state plus an [upcoming] list of
/// daily schedules covering the next month, so the widget keeps ticking
/// across day boundaries without the app being reopened.
class WidgetPayloadMapper {
  const WidgetPayloadMapper();

  WidgetPayload? map({
    required PrayerState state,
    required AppSettings settings,
    required AppLocalizations l,
    required List<DailyPrayerTimes> upcoming,
  }) {
    if (upcoming.isEmpty) return null;
    final slots = _slotsFromDays(upcoming, l);
    if (slots.isEmpty) return null;

    return WidgetPayload(
      slots: slots,
      cityLabel: cityLabel(
        settings.selectedCity,
        locale: settings.locale,
        countryKey: settings.selectedCountry,
      ),
      hijriLabel: formatHijriDateLocalized(l, state.now),
      gradientKey: state.nextPrayerKey.isEmpty ? 'fajr' : state.nextPrayerKey,
      remainingTemplateHm: _toTemplate(l.remainingHoursMinutes(_hSig, _mSig)),
      remainingTemplateH: _toTemplate(l.remainingHours(_hSig)),
      remainingTemplateM: _toTemplate(l.remainingMinutes(_mSig)),
      remainingNowLabel: '—',
    );
  }

  List<WidgetPrayerSlot> _slotsFromDays(
    List<DailyPrayerTimes> days,
    AppLocalizations l,
  ) => [
    for (final day in days)
      for (final p in day.prayersOnly)
        WidgetPrayerSlot(
          key: p.key,
          label: localizedPrayerNameFromLocalizations(l, p.key),
          timeLabel: _hhmm(p.time),
          timestampMillis: p.time.millisecondsSinceEpoch,
        ),
  ];

  static const int _hSig = 91;
  static const int _mSig = 92;
  String _toTemplate(String s) =>
      s.replaceAll('$_hSig', '{h}').replaceAll('$_mSig', '{m}');

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
