import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../bloc/hero_card_logic.dart';
import 'adhkar_hero_container.dart';
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
    // Light mode: pre-composite the palette tints onto [bgSurface] so the
    // card stays opaque against the warm parchment background. Dark mode
    // keeps the original translucent look since the dark gradient already
    // blends well behind the card.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.transparent : ThemeColors.of(false).bgSurface;
    final tintTop = isDark
        ? palette.primary.withValues(alpha: 0.08)
        : Color.alphaBlend(palette.primary.withValues(alpha: 0.08), base);
    final tintBottom = isDark
        ? palette.secondary.withValues(alpha: 0.03)
        : Color.alphaBlend(palette.secondary.withValues(alpha: 0.03), base);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.025,
        vertical: screenH * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tintTop, tintBottom],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
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
      case HeroCardMode.adhkar:
        return AdhkarHeroContainer(
          key: ValueKey('adhkar_${model.session.name}'),
          session: model.session,
        );
      case HeroCardMode.nextPrayer:
        return const NextPrayerContent(key: ValueKey('next'));
    }
  }
}
