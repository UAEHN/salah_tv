import 'package:adhan_dart/adhan_dart.dart';

import '../domain/entities/daily_prayer_times.dart';
import 'calculation_method_map.dart';

/// Wraps [adhan_dart] to produce [DailyPrayerTimes] from coordinates.
///
/// This is the only file that imports `adhan_dart` for calculation.
/// Returned DateTimes are in the target city's timezone when
/// [utcOffsetHours] is provided, otherwise device local timezone.
class AdhanCalculationSource {
  /// Calculates prayer times for [date] at ([lat], [lng]) using [methodKey]
  /// and [madhabKey] ('shafi' or 'hanafi' — affects Asr time only).
  ///
  /// When [utcOffsetHours] is non-null, times are shifted to that UTC offset
  /// so they display correctly for the target city regardless of the device's
  /// own timezone.
  DailyPrayerTimes calculateForDate(
    double lat,
    double lng,
    DateTime date,
    String methodKey, {
    String madhabKey = 'shafi',
    double? utcOffsetHours,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = calculationParametersFor(methodKey);
    if (madhabKey == 'hanafi') params.madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
    );

    DateTime convert(DateTime utc) => utcOffsetHours != null
        ? _toTargetTimezone(utc, utcOffsetHours)
        : utc.toLocal();

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

  /// Converts a UTC [DateTime] to the target timezone by applying
  /// [offsetHours] (e.g. 2.0 for GMT+2, -5.0 for GMT-5).
  /// Returns a non-UTC DateTime whose hour/minute represent the city's
  /// wall-clock time — suitable for display and minute-of-day comparisons.
  static DateTime _toTargetTimezone(DateTime utc, double offsetHours) {
    final shifted = utc.toUtc().add(
      Duration(minutes: (offsetHours * 60).round()),
    );
    // Re-wrap as local-labelled DateTime so formatters show the shifted time.
    return DateTime(
      shifted.year, shifted.month, shifted.day,
      shifted.hour, shifted.minute, shifted.second,
    );
  }
}
