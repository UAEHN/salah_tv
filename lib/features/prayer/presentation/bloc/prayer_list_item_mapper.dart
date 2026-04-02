import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import 'prayer_ui_logic.dart';

class PrayerPanelItem {
  final PrayerEntry prayer;
  final bool isNext;
  final int iqamaDelay;
  final int adhanOffset;

  const PrayerPanelItem({
    required this.prayer,
    required this.isNext,
    required this.iqamaDelay,
    required this.adhanOffset,
  });
}

class PrayerCardStripItem {
  final PrayerEntry prayer;
  final bool isNext;
  final bool isPassed;
  final bool isPreAlert;
  final int iqamaDelay;
  final int adhanOffset;

  const PrayerCardStripItem({
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.isPreAlert,
    required this.iqamaDelay,
    required this.adhanOffset,
  });
}

List<PrayerPanelItem> mapPrayerPanelItems({
  required DailyPrayerTimes today,
  required String nextPrayerKey,
  required AppSettings settings,
}) {
  return today.prayers
      .map(
        (prayer) => PrayerPanelItem(
          prayer: prayer,
          isNext: prayer.key == nextPrayerKey,
          iqamaDelay: settings.iqamaDelays[prayer.key] ?? 10,
          adhanOffset: settings.adhanOffsets[prayer.key] ?? 0,
        ),
      )
      .toList(growable: false);
}

List<PrayerCardStripItem> mapPrayerCardStripItems({
  required DailyPrayerTimes today,
  required String activePrayerKey,
  required bool isPrePrayerAlert,
  required AppSettings settings,
}) {
  return today.prayers.reversed
      .map((prayer) {
        final isNext = prayer.key == activePrayerKey;
        return PrayerCardStripItem(
          prayer: prayer,
          isNext: isNext,
          isPassed: isPrayerPassedByOrder(
            prayerKey: prayer.key,
            activeKey: activePrayerKey,
          ),
          isPreAlert: isNext && isPrePrayerAlert,
          iqamaDelay: settings.iqamaDelays[prayer.key] ?? 10,
          adhanOffset: settings.adhanOffsets[prayer.key] ?? 0,
        );
      })
      .toList(growable: false);
}
