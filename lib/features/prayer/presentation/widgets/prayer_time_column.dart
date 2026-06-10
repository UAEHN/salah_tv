import 'package:flutter/material.dart';

import 'classic/classic_visuals.dart';

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

/// Centered time cell for a classic prayer row: a prominent Adhan time with a
/// small day-period suffix, and the Iqama time stacked beneath it (or an em
/// dash when the prayer has no Iqama, e.g. sunrise).
class PrayerTimeColumn extends StatelessWidget {
  final String adhanTime;
  final String? adhanPeriod;
  final String iqamaTime;
  final String? iqamaPeriod;
  final bool isCountable;
  final bool isNext;
  final ClassicVisuals vis;
  final double screenH;

  const PrayerTimeColumn({
    super.key,
    required this.adhanTime,
    required this.adhanPeriod,
    required this.iqamaTime,
    required this.iqamaPeriod,
    required this.isCountable,
    required this.isNext,
    required this.vis,
    required this.screenH,
  });

  @override
  Widget build(BuildContext context) {
    final adhanColor = isNext ? vis.onAccent : vis.fg;
    final iqamaColor = isNext ? vis.onAccent : vis.fgMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              adhanTime,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: screenH * 0.050,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                color: adhanColor,
              ),
            ),
            if (adhanPeriod != null) ...[
              SizedBox(width: screenH * 0.006),
              Text(
                adhanPeriod!,
                style: TextStyle(
                  fontSize: screenH * 0.023,
                  fontWeight: FontWeight.w600,
                  color: isNext ? vis.onAccent : vis.fgMuted,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: screenH * 0.004),
        if (isCountable)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                iqamaTime,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: screenH * 0.022,
                  fontWeight: FontWeight.w500,
                  color: iqamaColor,
                ),
              ),
              if (iqamaPeriod != null) ...[
                SizedBox(width: screenH * 0.004),
                Text(
                  iqamaPeriod!,
                  style: TextStyle(
                    fontSize: screenH * 0.020,
                    fontWeight: FontWeight.w500,
                    color: iqamaColor,
                  ),
                ),
              ],
            ],
          )
        else
          Text(
            '—',
            style: TextStyle(
              fontSize: screenH * 0.022,
              fontWeight: FontWeight.w500,
              color: iqamaColor.withValues(alpha: 0.55),
            ),
          ),
      ],
    );
  }
}
