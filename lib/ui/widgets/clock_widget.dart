import 'package:flutter/material.dart';

import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';

class ClockWidget extends StatelessWidget {
  final AccentPalette palette;
  const ClockWidget({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final now = context.watch<PrayerProvider>().now;
    final screenH = MediaQuery.of(context).size.height;

    final timeStr = settings.use24HourFormat
        ? DateFormat('HH:mm').format(now)
        : DateFormat('hh:mm').format(now);
    final secondsStr = DateFormat(':ss').format(now);

    final tc = ThemeColors.of(settings.isDarkMode);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: RichText(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: timeStr,
          style: TextStyle(
            fontSize: screenH * 0.18,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
            letterSpacing: 4,
            height: 1.0,
          ),
          children: [
            TextSpan(
              text: secondsStr,
              style: TextStyle(
                fontSize: screenH * 0.08,
                fontWeight: FontWeight.w700,
                color: tc.textSecondary,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
