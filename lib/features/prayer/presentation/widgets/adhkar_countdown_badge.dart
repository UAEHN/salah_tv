import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

/// Full-width header row: session label (right) + countdown badge (left).
class AdhkarCountdownBadge extends StatelessWidget {
  final String sessionLabel;
  final String prayerName;
  final String countdown;
  final double screenH;
  final ThemeColors tc;

  const AdhkarCountdownBadge({
    required this.sessionLabel,
    required this.prayerName,
    required this.countdown,
    required this.screenH,
    required this.tc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          sessionLabel,
          style: TextStyle(
            fontSize: screenH * 0.028,
            color: tc.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                color: tc.textPrimary,
                size: screenH * 0.024,
              ),
              const SizedBox(width: 6),
              Text(
                '$prayerName  $countdown',
                style: TextStyle(
                  fontSize: screenH * 0.022,
                  color: tc.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
