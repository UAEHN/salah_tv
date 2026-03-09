import 'package:flutter/material.dart';

import 'package:intl/intl.dart' hide TextDirection;
import '../../../../models/daily_prayer_times.dart';
import '../../../../models/app_settings.dart';
import '../../../../core/app_colors.dart';

class PrayerRow extends StatelessWidget {
  final PrayerEntry prayer;
  final bool isNext;
  final AppSettings settings;
  final int iqamaDelay;
  final int adhanOffset;

  const PrayerRow({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.settings,
    required this.iqamaDelay,
    this.adhanOffset = 0,
  });

  String _formatTime(DateTime dt) {
    if (settings.use24HourFormat) {
      return DateFormat('HH:mm').format(dt);
    } else {
      return DateFormat('hh:mm').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final adjustedTime = prayer.time.add(Duration(minutes: adhanOffset));
    final iqamaTime = adjustedTime.add(Duration(minutes: iqamaDelay));
    final screenH = MediaQuery.of(context).size.height;

    // الألوان تعتمد على الوضع فقط — بغض النظر عن لون الثيم
    final timeColor = tc.textPrimary;
    final nameColor = isNext ? tc.textPrimary : tc.textSecondary;
    final iconColor = isNext ? tc.textPrimary : tc.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        gradient: isNext
            ? LinearGradient(
                colors: [
                  palette.primary.withValues(alpha: 0.18),
                  palette.secondary.withValues(alpha: 0.08),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              )
            : null,
        color: isNext ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenH * 0.032,
        vertical: screenH * 0.015,
      ),
      child: Row(
        children: [
          // Time column (adhan + iqama)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatTime(adjustedTime),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: screenH * 0.053,
                  fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                  color: timeColor,
                  shadows: isNext
                      ? [
                          Shadow(
                            color: palette.glow.withValues(alpha: 0.35),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
              ),
              if (prayer.isCountable) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'إقامة ',
                      style: TextStyle(
                        fontSize: screenH * 0.022,
                        color: tc.textMuted,
                      ),
                    ),
                    Text(
                      _formatTime(iqamaTime),
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: screenH * 0.026,
                        fontWeight: FontWeight.w400,
                        color: tc.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // Prayer name
          Expanded(
            child: Text(
              prayer.name,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenH * 0.056,
                fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                color: nameColor,
              ),
            ),
          ),
          SizedBox(width: screenH * 0.022),
          Icon(
            _getIconForPrayer(prayer.key),
            size: screenH * 0.042,
            color: iconColor,
          ),
        ],
      ),
    );
  }

  IconData _getIconForPrayer(String key) {
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
}
