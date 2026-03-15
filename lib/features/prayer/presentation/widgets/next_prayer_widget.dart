import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/time_formatters.dart';
import '../../../../core/widgets/flip_clock.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';

class NextPrayerWidget extends StatelessWidget {
  final AccentPalette palette;

  const NextPrayerWidget({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerBloc>().state;
    final isDark = context.watch<SettingsProvider>().settings.isDarkMode;
    final tc = ThemeColors.of(isDark);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.03,
        vertical: screenH * 0.025,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.55),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            'الصلاة القادمة',
            style: TextStyle(
              fontSize: screenH * 0.040,
              fontWeight: FontWeight.w400,
              color: tc.textSecondary,
            ),
          ),
          // اسم الصلاة — أبيض في الداكن، أسود في الفاتح
          Text(
            prayer.nextPrayerName,
            style: TextStyle(
              fontSize: screenH * 0.09,
              fontWeight: FontWeight.w600,
              color: tc.textPrimary,
              height: 1.1,
              shadows: [
                Shadow(
                  color: palette.glow.withValues(alpha: 0.4),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          SizedBox(height: screenH * 0.01),
          // Countdown
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                color: tc.textSecondary,
                size: screenH * 0.035,
              ),
              SizedBox(width: screenW * 0.008),
              FlipClock(
                text: formatCountdown(prayer.countdown),
                style: TextStyle(
                  fontSize: screenH * 0.060,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                ),
                digitWidth: screenH * 0.060 * 0.68,
                digitHeight: screenH * 0.060 * 1.22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
