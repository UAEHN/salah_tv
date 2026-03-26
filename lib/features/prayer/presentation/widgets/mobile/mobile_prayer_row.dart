import 'package:flutter/material.dart';
import '../../../domain/entities/daily_prayer_times.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';

const _prayerIcons = {
  'fajr': Icons.nights_stay_outlined,
  'dhuhr': Icons.light_mode_outlined,
  'asr': Icons.wb_sunny_outlined,
  'maghrib': Icons.wb_twilight_rounded,
  'isha': Icons.stars_outlined,
};

class MobilePrayerRow extends StatelessWidget {
  final PrayerEntry prayer;
  final bool isActive;
  final bool is24HourFormat;
  final int adhanOffset;

  const MobilePrayerRow({
    super.key,
    required this.prayer,
    required this.isActive,
    required this.is24HourFormat,
    this.adhanOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _prayerIcons[prayer.key] ?? Icons.access_time_outlined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: isActive
          ? MobileDecorations.activePillCard(context)
          : MobileDecorations.pillCard(context),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.15)
                    : MobileColors.shadowDark(context),
              ),
              child: Icon(
                icon,
                color: isActive
                    ? Colors.white
                    : MobileColors.onSurfaceMuted(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Prayer name + active label
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Fixes overflow by not taking max height
                children: [
                  Text(
                    prayer.name,
                    style: MobileTextStyles.titleMd(context).copyWith(
                      color: isActive
                          ? Colors.white
                          : MobileColors.onSurface(context),
                      height: 1.0,
                    ),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'الصلاة القادمة',
                            style: MobileTextStyles.labelSm(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Time (adjusted by adhan offset)
            Builder(builder: (context) {
              final adjustedTime = prayer.time.add(
                Duration(minutes: adhanOffset),
              );
              final timeColor = isActive
                  ? Colors.white
                  : MobileColors.onSurfaceMuted(context);
              final period = formatPrayerPeriod(
                adjustedTime,
                use24Hour: is24HourFormat,
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (period != null) ...[
                    Text(
                      period,
                      style: MobileTextStyles.labelSm(context).copyWith(
                        fontSize: 11,
                        color: timeColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    formatPrayerTime(
                      adjustedTime,
                      use24Hour: is24HourFormat,
                    ),
                    style: MobileTextStyles.titleMd(context).copyWith(
                      fontSize: 22,
                      color: timeColor,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
