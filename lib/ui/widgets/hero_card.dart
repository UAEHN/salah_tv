import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    final isIqama = prayerProv.isIqamaCountdown;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.025,
        vertical: screenH * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.primary.withValues(alpha: 0.08),
            palette.secondary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: palette.primary.withValues(alpha: isIqama ? 0.7 : 0.4),
          width: isIqama ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.glow.withValues(alpha: isIqama ? 0.2 : 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: isIqama
            ? _IqamaContent(key: const ValueKey('iqama'))
            : _NextPrayerContent(key: const ValueKey('next')),
      ),
    );
  }
}

class _NextPrayerContent extends StatelessWidget {
  const _NextPrayerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label
        Text(
          'الصلاة القادمة',
          style: TextStyle(
            fontSize: screenH * 0.045,
            fontWeight: FontWeight.w400,
            color: tc.textSecondary,
          ),
        ),
        SizedBox(height: screenH * 0.01),
        // Prayer name
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            prayerProv.nextPrayerName,
            key: ValueKey(prayerProv.nextPrayerName),
            style: TextStyle(
              fontSize: screenH * 0.12,
              fontWeight: FontWeight.w700,
              color: palette.primary,
              height: 1.1,
              shadows: [Shadow(color: palette.glow, blurRadius: 18)],
            ),
          ),
        ),
        SizedBox(height: screenH * 0.015),
        // Countdown
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: palette.primary,
              size: screenH * 0.05,
            ),
            const SizedBox(width: 12),
            _AnimatedCountdown(
              text: prayerProv.formatCountdown(prayerProv.countdown),
              style: TextStyle(
                fontSize: screenH * 0.10,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IqamaContent extends StatelessWidget {
  const _IqamaContent({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label
        Text(
          'إقامة صلاة ${prayerProv.iqamaPrayerName} بعد',
          style: TextStyle(
            fontSize: screenH * 0.048,
            fontWeight: FontWeight.w500,
            color: palette.primary,
          ),
        ),
        SizedBox(height: screenH * 0.015),
        // Countdown
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_filled_rounded,
              color: palette.primary,
              size: screenH * 0.050,
            ),
            const SizedBox(width: 12),
            _AnimatedCountdown(
              text: prayerProv.formatIqamaCountdown(prayerProv.iqamaCountdown),
              style: TextStyle(
                fontSize: screenH * 0.10,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
                letterSpacing: 2,
                shadows: [Shadow(color: palette.glow, blurRadius: 12)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Plain countdown text — no per-character animation (matches classic layout).
class _AnimatedCountdown extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _AnimatedCountdown({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(text, style: style),
    );
  }
}
