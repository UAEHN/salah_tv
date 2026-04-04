import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/app_colors.dart';
import 'islamic_arch_shape.dart';

class PrayerCardContent extends StatelessWidget {
  final double pulse;
  final bool isPreAlert;
  final bool isNext;
  final bool isDarkMode;
  final AccentPalette palette;
  final ThemeColors tc;
  final double screenH;
  final PrayerEntry prayer;
  final String formattedTime;
  final String formattedIqama;
  final IconData icon;

  const PrayerCardContent({
    super.key,
    required this.pulse,
    required this.isPreAlert,
    required this.isNext,
    required this.isDarkMode,
    required this.palette,
    required this.tc,
    required this.screenH,
    required this.prayer,
    required this.formattedTime,
    required this.formattedIqama,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final borderColor = isPreAlert
        ? palette.primary.withValues(alpha: 0.30 + pulse * 0.20)
        : isNext
            ? palette.primary.withValues(alpha: 0.5)
            : tc.borderGlass;

    final shadowColor = isPreAlert
        ? palette.primary.withValues(alpha: 0.08 + pulse * 0.12)
        : isNext
            ? palette.glow.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04);

    final fillColor = isNext ? null : tc.bgSurface;
    final fillGradient = isNext
        ? LinearGradient(
            colors: [
              palette.primary.withValues(alpha: 0.15),
              palette.secondary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : null;

    return CustomPaint(
      painter: IslamicArchPainter(
        fillColor: fillColor,
        gradient: fillGradient,
        borderColor: borderColor,
        borderWidth: isNext ? 1.5 : 1,
        shadowColor: shadowColor,
        shadowBlur: isPreAlert ? 8 + pulse * 6 : (isNext ? 12 : 8),
      ),
      child: ClipPath(
        clipper: IslamicArchClipper(),
        child: _buildCardBody(context, l),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context, AppLocalizations l) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        SizedBox(height: screenH * 0.008),
        Icon(
          icon,
          size: screenH * 0.050,
          color: isNext ? tc.textPrimary : tc.textSecondary,
        ),
        SizedBox(height: screenH * 0.008),
        Text(
          localizedPrayerName(context, prayer.key),
          style: TextStyle(
            fontSize: screenH * 0.040,
            fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
            color: tc.textPrimary,
          ),
        ),
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
        Text(
          formattedTime,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: screenH * 0.045,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
          ),
        ),
        if (prayer.isCountable) ...[
          SizedBox(height: screenH * 0.002),
          Text(
            '${l.iqamaLabel} $formattedIqama',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: screenH * 0.026,
              color: tc.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
