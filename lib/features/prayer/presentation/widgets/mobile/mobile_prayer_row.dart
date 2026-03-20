import 'package:flutter/material.dart';
import '../../../domain/entities/daily_prayer_times.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';

const _prayerIcons = {
  'fajr': Icons.dark_mode_outlined,
  'dhuhr': Icons.light_mode_outlined,
  'asr': Icons.wb_sunny,
  'maghrib': Icons.wb_twilight,
  'isha': Icons.stars,
};

class MobilePrayerRow extends StatelessWidget {
  final PrayerEntry prayer;
  final bool isActive;
  final bool use24Hour;

  const MobilePrayerRow({
    super.key,
    required this.prayer,
    required this.isActive,
    required this.use24Hour,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _prayerIcons[prayer.key] ?? Icons.access_time_outlined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: isActive
          ? MobileDecorations.activePillCard()
          : MobileDecorations.pillCard(),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
          // Icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : MobileColors.cardColor,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : MobileColors.onSurfaceMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Prayer name + active label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.name,
                  style: MobileTextStyles.headlineMd.copyWith(
                    color: isActive ? Colors.white : MobileColors.onSurface,
                  ),
                ),
                if (isActive)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'الصلاة القادمة',
                        style: MobileTextStyles.labelSm.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Time
          Text(
            formatPrayerTime(prayer.time, use24Hour: use24Hour),
            style: MobileTextStyles.titleMd.copyWith(
              fontSize: 20,
              color: isActive ? Colors.white : MobileColors.onSurfaceMuted,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
