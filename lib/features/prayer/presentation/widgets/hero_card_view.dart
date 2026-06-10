import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/hero_card_logic.dart';
import 'iqama_content.dart';
import 'next_prayer_content.dart';

class HeroCardView extends StatelessWidget {
  final HeroCardModel model;
  final AccentPalette palette;
  final double screenW;
  final double screenH;

  const HeroCardView({
    super.key,
    required this.model,
    required this.palette,
    required this.screenW,
    required this.screenH,
  });

  @override
  Widget build(BuildContext context) {
    final isIqama = model.mode == HeroCardMode.iqama;
    // Single solid color matching [InfoCard] — no gradient, no per-stop
    // alpha. Cheap Android TV GPUs misrender LinearGradients between two
    // semi-transparent colors; using one flat color avoids that path
    // entirely and keeps the hero card and clock card visually consistent.
    // Source of brightness MUST match InfoCard / PrayerCardContent (both
    // read `settings.isDarkMode` directly) so all three cards always pick
    // the same `tc.bgSurface` shade — otherwise they can diverge when
    // `themeMode == 'system'`.
    final isDark = context.select<SettingsProvider, bool>(
      (p) => p.settings.isDarkMode,
    );
    final tc = ThemeColors.of(isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.025,
        vertical: screenH * 0.02,
      ),
      decoration: BoxDecoration(
        color: tc.bgSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: palette.primary.withValues(alpha: isIqama ? 0.7 : 0.4),
          width: isIqama ? 2.5 : 1.5,
        ),
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (model.mode) {
      case HeroCardMode.iqama:
        return const IqamaContent(key: ValueKey('iqama'));
      case HeroCardMode.nextPrayer:
        return const NextPrayerContent(key: ValueKey('next'));
    }
  }
}
