import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../models/daily_prayer_times.dart';
import '../../../../models/app_settings.dart';
import '../../../../core/app_colors.dart';

class PrayerCard extends StatelessWidget {
  final PrayerEntry prayer;
  final bool isNext;
  final bool isPassed;
  final AppSettings settings;
  final int iqamaDelay;
  final int adhanOffset;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.settings,
    required this.iqamaDelay,
    this.adhanOffset = 0,
  });

  String _formatTime(DateTime dt) {
    if (settings.use24HourFormat) {
      return DateFormat('HH:mm').format(dt);
    }
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'ص' : 'م';
    return '$hour:$min $period';
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'sunrise':
        return Icons.brightness_high_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.brightness_4_rounded;
      case 'isha':
        return Icons.nights_stay_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;
    final adjustedTime = prayer.time.add(Duration(minutes: adhanOffset));
    final iqamaTime = adjustedTime.add(Duration(minutes: iqamaDelay));

    // الألوان تعتمد على الوضع الداكن/الفاتح فقط — بغض النظر عن لون الثيم
    final iconColor = isNext ? tc.textPrimary : tc.textSecondary;
    final nameColor = isNext ? tc.textPrimary : tc.textPrimary;
    final timeColor = isNext ? tc.textPrimary : tc.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isNext ? null : tc.bgSurface,
        gradient: isNext
            ? LinearGradient(
                colors: [
                  palette.primary.withValues(alpha: 0.15),
                  palette.secondary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? palette.primary.withValues(alpha: 0.5)
              : tc.borderGlass,
          width: isNext ? 1.5 : 1,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: settings.isDarkMode ? 0.2 : 0.04,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top accent bar for next prayer
          if (isNext)
            Container(
              height: 3,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
              decoration: BoxDecoration(
                gradient: palette.horizontalGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          SizedBox(height: screenH * 0.008),

          // Icon
          Icon(_getIcon(prayer.key), size: screenH * 0.050, color: iconColor),

          SizedBox(height: screenH * 0.008),

          // Prayer name
          Text(
            prayer.name,
            style: TextStyle(
              fontSize: screenH * 0.040,
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              color: nameColor,
            ),
          ),

          // Divider
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: screenH * 0.006,
            ),
            color: isNext
                ? palette.primary.withValues(alpha: 0.25)
                : tc.borderGlass,
          ),

          // Adhan time
          Text(
            _formatTime(adjustedTime),
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: screenH * 0.045,
              fontWeight: FontWeight.w700,
              color: timeColor,
            ),
          ),

          // Iqama time
          if (prayer.isCountable) ...[
            SizedBox(height: screenH * 0.002),
            Text(
              'إقامة ${_formatTime(iqamaTime)}',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: screenH * 0.026, color: tc.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
