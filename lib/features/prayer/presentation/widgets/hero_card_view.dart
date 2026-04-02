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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
