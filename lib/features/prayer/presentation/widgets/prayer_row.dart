import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../domain/entities/daily_prayer_times.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../../core/app_colors.dart';
import 'prayer_time_column.dart';

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

    // Colors depend on the active mode only, regardless of theme color.
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
          PrayerTimeColumn(
            adhanTime: _formatTime(adjustedTime),
            iqamaTime: _formatTime(iqamaTime),
            isCountable: prayer.isCountable,
            isNext: isNext,
            tc: tc,
            palette: palette,
            screenH: screenH,
          ),
          // Prayer name
          Expanded(
            child: Text(
              localizedPrayerName(context, prayer.key),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenH * 0.056,
                fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                color: nameColor,
              ),
            ),
          ),
          SizedBox(width: screenH * 0.022),
          Icon(prayerIcon(prayer.key), size: screenH * 0.042, color: iconColor),
        ],
      ),
    );
  }
}
