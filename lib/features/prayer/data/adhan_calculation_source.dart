import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';

import '../domain/entities/daily_prayer_times.dart';
import '../domain/prayer_time_zone.dart';
import 'calculation_method_map.dart';
import 'high_latitude_rule_map.dart';

/// Wraps [adhan_dart] to produce [DailyPrayerTimes] from coordinates.
///
/// This is the only file that imports `adhan_dart` for calculation.
/// Returned DateTimes are in the target city's timezone when
/// [timeZoneId] or [utcOffsetHours] is provided, otherwise device local
/// timezone.
class AdhanCalculationSource {
  /// Above this absolute latitude the sun no longer dips deep enough below
  /// the horizon in summer for a standard 12–18° twilight angle to produce
  /// a real Fajr/Isha time. When the user has not explicitly chosen a
  /// high-latitude rule (i.e. [HighLatitudeRuleKey.auto]) we apply a safe,
  /// gradual fallback that matches what mainstream Islamic apps publish.
  /// 48.5° just covers Paris (48.85°N) and northward.
  static const double _kHighLatitudeThreshold = 48.5;

  /// Calculates prayer times for [date] at ([lat], [lng]) using [methodKey]
  /// and [madhabKey] ('shafi' or 'hanafi' — affects Asr time only).
  ///
  /// [highLatitudeRuleKey] selects the high-latitude adjustment. Pass
  /// [HighLatitudeRuleKey.auto] to keep the legacy auto-pick (apply
  /// `middleOfTheNight` only above [_kHighLatitudeThreshold]). Any other
  /// value is honored unconditionally so the user gets the rule their
  /// local mosque actually uses.
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
    String highLatitudeRuleKey = HighLatitudeRuleKey.auto,
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = calculationParametersFor(methodKey);
    if (madhabKey == 'hanafi') params.madhab = Madhab.hanafi;

    final explicitRule = highLatitudeRuleFor(highLatitudeRuleKey);
    if (explicitRule != null) {
      params.highLatitudeRule = explicitRule;
    } else if (lat.abs() > _kHighLatitudeThreshold) {
      // See `_kHighLatitudeThreshold` doc for why twilightAngle is the
      // auto choice: it scales the Fajr/Isha angles down proportionally
      // with day length, giving the widest astronomically-defensible
      // spread in summer (matches Muslim Pro / IslamicFinder defaults
      // and the user-reported reference values for Berlin).
      params.highLatitudeRule = HighLatitudeRule.twilightAngle;
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

    final result = DailyPrayerTimes(
      date: DateTime(date.year, date.month, date.day),
      fajr: convert(prayerTimes.fajr),
      sunrise: convert(prayerTimes.sunrise),
      dhuhr: convert(prayerTimes.dhuhr),
      asr: convert(prayerTimes.asr),
      maghrib: convert(prayerTimes.maghrib),
      isha: convert(prayerTimes.isha),
    );

    assert(() {
      if (!_isMonotonic(result)) {
        debugPrint(
          '[AdhanCalculationSource] non-monotonic times at '
          '($lat, $lng) on $date — method=$methodKey '
          'rule=$highLatitudeRuleKey result=$result',
        );
      }
      return true;
    }());

    return result;
  }

  /// Returns true when the six daily prayer times appear in the expected
  /// chronological order. Adhan_dart can occasionally return out-of-order
  /// times near the poles in mid-summer or mid-winter — callers should
  /// treat a `false` result as a calculation failure and fall back.
  static bool _isMonotonic(DailyPrayerTimes t) {
    return t.fajr.isBefore(t.sunrise) &&
        t.sunrise.isBefore(t.dhuhr) &&
        t.dhuhr.isBefore(t.asr) &&
        t.asr.isBefore(t.maghrib) &&
        t.maghrib.isBefore(t.isha);
  }

  /// Public wrapper for the monotonic check — repositories use this to
  /// decide whether to keep a result or fall back to yesterday's times.
  static bool isValid(DailyPrayerTimes t) => _isMonotonic(t);
}
