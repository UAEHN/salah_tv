import 'package:adhan_dart/adhan_dart.dart';

import '../domain/entities/daily_prayer_times.dart';
import '../domain/prayer_time_zone.dart';
import 'calculation_method_map.dart';

/// Wraps [adhan_dart] to produce [DailyPrayerTimes] from coordinates.
///
/// This is the only file that imports `adhan_dart` for calculation.
/// Returned DateTimes are in the target city's timezone when
/// [timeZoneId] or [utcOffsetHours] is provided, otherwise device local
/// timezone.
class AdhanCalculationSource {
  /// Above this absolute latitude the sun no longer dips deep enough below
  /// the horizon in summer for a standard 12–18° twilight angle to produce
  /// a real Fajr/Isha time. We apply [HighLatitudeRule.middleOfTheNight]
  /// as a safe, conservative fallback (matches what most European mosques
  /// publish). 48.5° just covers Paris (48.85°N) and northward.
  static const double _kHighLatitudeThreshold = 48.5;

  /// Calculates prayer times for [date] at ([lat], [lng]) using [methodKey]
  /// and [madhabKey] ('shafi' or 'hanafi' — affects Asr time only).
  ///
  /// When [timeZoneId] is non-null, times are shifted using the real timezone
  /// rules for that city (including DST). Otherwise [utcOffsetHours] is used
  /// as a fixed fallback.
  DailyPrayerTimes calculateForDate(
    double lat,
    double lng,
    DateTime date,
    String methodKey, {
    String madhabKey = 'shafi',
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = calculationParametersFor(methodKey);
    if (madhabKey == 'hanafi') params.madhab = Madhab.hanafi;
    if (lat.abs() > _kHighLatitudeThreshold) {
      params.highLatitudeRule = HighLatitudeRule.middleOfTheNight;
    }

    final prayerTimes = PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
    );

    DateTime convert(DateTime utc) => PrayerTimeZone.fromUtc(
      utc,
      timeZoneId: timeZoneId,
      utcOffsetHours: utcOffsetHours,
    );

    return DailyPrayerTimes(
      date: DateTime(date.year, date.month, date.day),
      fajr: convert(prayerTimes.fajr),
      sunrise: convert(prayerTimes.sunrise),
      dhuhr: convert(prayerTimes.dhuhr),
      asr: convert(prayerTimes.asr),
      maghrib: convert(prayerTimes.maghrib),
      isha: convert(prayerTimes.isha),
    );
  }

}
