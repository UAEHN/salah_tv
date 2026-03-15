import 'package:flutter/material.dart';
import '../../../../core/time_formatters.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';

/// Prayer name + countdown text shown over the Makkah live video.
class PrayerTextOverlay extends StatelessWidget {
  final PrayerState prayer;
  final double screenH;

  const PrayerTextOverlay({
    required this.prayer,
    required this.screenH,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'الصلاة القادمة',
          style: TextStyle(
            fontSize: screenH * 0.038,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          prayer.nextPrayerName,
          style: TextStyle(
            fontSize: screenH * 0.10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 12)],
          ),
        ),
        SizedBox(height: screenH * 0.005),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            formatCountdown(prayer.countdown),
            style: TextStyle(
              fontSize: screenH * 0.075,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }
}
