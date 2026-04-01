import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';

IconData prayerIcon(String key) {
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

class PrayerTimeColumn extends StatelessWidget {
  final String adhanTime;
  final String iqamaTime;
  final bool isCountable;
  final bool isNext;
  final ThemeColors tc;
  final AccentPalette palette;
  final double screenH;

  const PrayerTimeColumn({
    super.key,
    required this.adhanTime,
    required this.iqamaTime,
    required this.isCountable,
    required this.isNext,
    required this.tc,
    required this.palette,
    required this.screenH,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          adhanTime,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: screenH * 0.053,
            fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
            color: tc.textPrimary,
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
        if (isCountable) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l.iqamaLabel} ',
                style: TextStyle(
                  fontSize: screenH * 0.022,
                  color: tc.textMuted,
                ),
              ),
              Text(
                iqamaTime,
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
    );
  }
}
