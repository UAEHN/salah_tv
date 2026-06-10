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

    // Active card uses a solid palette color (mirrors mobile active row) so the
    // selection reads at a glance from across the room. On dark mode we darken
    // the primary slightly so it doesn't glow harder than the surface around it.
    final activeFill = isDarkMode
        ? Color.lerp(palette.primary, Colors.black, 0.20) ?? palette.primary
        : palette.primary;

    final borderColor = isPreAlert
        ? palette.primary.withValues(alpha: 0.30 + pulse * 0.20)
        : isNext
        ? Colors.white.withValues(alpha: isDarkMode ? 0.18 : 0.35)
        : tc.borderGlass;

    final shadowColor = isPreAlert
        ? palette.primary.withValues(alpha: 0.08 + pulse * 0.12)
        : isNext
        ? palette.glow.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04);

    final fillColor = isNext ? activeFill : tc.bgSurface;
    const Gradient? fillGradient = null;

    return CustomPaint(
      painter: IslamicArchPainter(
        fillColor: fillColor,
        gradient: fillGradient,
        borderColor: borderColor,
        borderWidth: isNext ? 2.5 : 1,
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
    // Active card is filled with the palette primary — force white text/icon
    // so it stays readable across every theme (gold, blue, purple, ...) and
    // both light/dark surfaces. Inactive cards keep the theme text colors.
    final Color contentPrimary = isNext ? Colors.white : tc.textPrimary;
    final Color contentSecondary = isNext
        ? Colors.white.withValues(alpha: 0.92)
        : tc.textSecondary;
    final Color contentMuted = isNext
        ? Colors.white.withValues(alpha: 0.78)
        : tc.textMuted;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: screenH * 0.008),
        Icon(
          icon,
          size: screenH * 0.050,
          color: isNext ? contentPrimary : contentSecondary,
        ),
        SizedBox(height: screenH * 0.008),
        Text(
          localizedPrayerName(context, prayer.key),
          style: TextStyle(
            fontSize: screenH * 0.040,
            fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
            color: contentPrimary,
          ),
        ),
        SizedBox(height: screenH * 0.010),
        Text(
          formattedTime,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: screenH * 0.045,
            fontWeight: FontWeight.w700,
            color: contentPrimary,
          ),
        ),
        if (prayer.isCountable) ...[
          SizedBox(height: screenH * 0.002),
          Text(
            '${l.iqamaLabel} $formattedIqama',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: screenH * 0.026, color: contentMuted),
          ),
        ],
      ],
    );
  }
}
