import '../../../../core/time_formatters.dart';

class PrayerTimeUiModel {
  final DateTime adjustedTime;
  final DateTime iqamaTime;
  final String timeText;
  final String iqamaText;
  final String? periodText;

  const PrayerTimeUiModel({
    required this.adjustedTime,
    required this.iqamaTime,
    required this.timeText,
    required this.iqamaText,
    required this.periodText,
  });
}

const List<String> _prayerOrder = [
  'fajr',
  'sunrise',
  'dhuhr',
  'asr',
  'maghrib',
  'isha',
];

String effectiveActivePrayerKey({
  required String activeCyclePrayerKey,
  required String nextPrayerKey,
}) {
  return activeCyclePrayerKey.isNotEmpty ? activeCyclePrayerKey : nextPrayerKey;
}

String resolveMobileActivePrayerKey({
  required bool isViewingToday,
  required String activeCyclePrayerKey,
  required String nextPrayerKey,
}) {
  if (!isViewingToday) return '';
  return effectiveActivePrayerKey(
    activeCyclePrayerKey: activeCyclePrayerKey,
    nextPrayerKey: nextPrayerKey,
  );
}

bool isPrayerPassedByOrder({
  required String prayerKey,
  required String activeKey,
}) {
  final activeIndex = _prayerOrder.indexOf(activeKey);
  if (activeIndex < 0) return false;
  final prayerIndex = _prayerOrder.indexOf(prayerKey);
  return prayerIndex >= 0 && prayerIndex < activeIndex;
}

bool isPrayerPassedByTime({
  required DateTime prayerTime,
  required DateTime? now,
  required String prayerKey,
  required String activeKey,
}) {
  if (now == null) return false;
  if (prayerKey == activeKey) return false;
  return prayerTime.isBefore(now);
}

DateTime adjustedPrayerTime(DateTime baseTime, int adhanOffsetMinutes) {
  return baseTime.add(Duration(minutes: adhanOffsetMinutes));
}

DateTime iqamaFromAdjustedTime(DateTime adjustedTime, int iqamaDelayMinutes) {
  return adjustedTime.add(Duration(minutes: iqamaDelayMinutes));
}

String formatAdjustedPrayerTime({
  required DateTime baseTime,
  required int adhanOffsetMinutes,
  required bool use24HourFormat,
  String? localeCode,
}) {
  final adjusted = adjustedPrayerTime(baseTime, adhanOffsetMinutes);
  return formatPrayerTime(
    adjusted,
    use24Hour: use24HourFormat,
    localeCode: localeCode,
  );
}

String formatIqamaTime({
  required DateTime baseTime,
  required int adhanOffsetMinutes,
  required int iqamaDelayMinutes,
  required bool use24HourFormat,
  String? localeCode,
}) {
  final adjusted = adjustedPrayerTime(baseTime, adhanOffsetMinutes);
  final iqama = iqamaFromAdjustedTime(adjusted, iqamaDelayMinutes);
  return formatPrayerTime(
    iqama,
    use24Hour: use24HourFormat,
    localeCode: localeCode,
  );
}

String? formatAdjustedPrayerPeriod({
  required DateTime baseTime,
  required int adhanOffsetMinutes,
  required bool use24HourFormat,
  String? localeCode,
}) {
  final adjusted = adjustedPrayerTime(baseTime, adhanOffsetMinutes);
  return formatPrayerPeriod(
    adjusted,
    use24Hour: use24HourFormat,
    localeCode: localeCode,
  );
}

PrayerTimeUiModel mapPrayerTimeUiModel({
  required DateTime baseTime,
  required int adhanOffsetMinutes,
  required int iqamaDelayMinutes,
  required bool use24HourFormat,
  String? localeCode,
}) {
  final adjusted = adjustedPrayerTime(baseTime, adhanOffsetMinutes);
  final iqama = iqamaFromAdjustedTime(adjusted, iqamaDelayMinutes);
  return PrayerTimeUiModel(
    adjustedTime: adjusted,
    iqamaTime: iqama,
    timeText: formatPrayerTime(
      adjusted,
      use24Hour: use24HourFormat,
      localeCode: localeCode,
    ),
    iqamaText: formatPrayerTime(
      iqama,
      use24Hour: use24HourFormat,
      localeCode: localeCode,
    ),
    periodText: formatPrayerPeriod(
      adjusted,
      use24Hour: use24HourFormat,
      localeCode: localeCode,
    ),
  );
}
