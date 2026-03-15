import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/time_formatters.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';

class IqamaCountdownWidget extends StatelessWidget {
  final AccentPalette palette;

  const IqamaCountdownWidget({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerBloc>().state;
    final isDark = context.watch<SettingsProvider>().settings.isDarkMode;
    final tc = ThemeColors.of(isDark);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    if (!prayer.isIqamaCountdown) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.03,
        vertical: screenH * 0.022,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.85),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            'إقامة صلاة ${prayer.iqamaPrayerName}  بعد ',
            style: TextStyle(
              fontSize: screenH * 0.040,
              fontWeight: FontWeight.w500,
              color: tc.textSecondary,
            ),
          ),
          SizedBox(height: screenH * 0.008),
          // Countdown
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                color: tc.textSecondary,
                size: screenH * 0.038,
              ),
              SizedBox(width: screenW * 0.008),
              Text(
                formatIqamaCountdown(prayer.iqamaCountdown),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: screenH * 0.065,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                  shadows: [Shadow(color: palette.glow, blurRadius: 12)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
