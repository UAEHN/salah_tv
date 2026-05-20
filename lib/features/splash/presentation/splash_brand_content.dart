import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../core/brand_colors.dart';
import 'splash_brand_tweens.dart';
import 'splash_shimmer_title.dart';

/// Center content: pulsing ornament, localized app title with shimmer + glow,
/// animated separator, and the Quranic verse sliding up.
class SplashBrandContent extends StatelessWidget {
  final AnimationController brandAnimation;
  final AnimationController shimmerAnimation;

  const SplashBrandContent({
    required this.brandAnimation,
    required this.shimmerAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    final t = SplashBrandTweens.fromController(brandAnimation);

    return AnimatedBuilder(
      animation: Listenable.merge([brandAnimation, shimmerAnimation]),
      builder: (_, _) {
        final pulse = (sin(shimmerAnimation.value * pi * 2) + 1) / 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: t.starFade,
              child: Transform.scale(
                scale: 0.9 + pulse * 0.2,
                child: Text(
                  '✦',
                  style: TextStyle(
                    fontSize: h * 0.035,
                    color: brandGold,
                    shadows: [
                      Shadow(
                        color: brandGold.withValues(alpha: 0.3 + pulse * 0.5),
                        blurRadius: 8 + pulse * 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.015),
            FadeTransition(
              opacity: t.titleFade,
              child: ScaleTransition(
                scale: t.titleScale,
                child: SizedBox(
                  width: w * 0.85,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SplashShimmerTitle(
                      height: h,
                      title: l.appTitle,
                      shimmerValue: shimmerAnimation.value,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),
            Transform.scale(
              scaleX: t.sepScale.value,
              child: Container(
                width: h * 0.35,
                height: 1.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, brandGold, Colors.transparent],
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.025),
            SlideTransition(
              position: t.verseSlide,
              child: FadeTransition(
                opacity: t.verseFade,
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: h * 0.030,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(text: l.splashVerseStart),
                      TextSpan(
                        text: l.splashVerseHighlight,
                        style: TextStyle(
                          color: brandGold,
                          fontWeight: FontWeight.w700,
                          shadows: [Shadow(color: brandGold, blurRadius: 12)],
                        ),
                      ),
                      TextSpan(text: l.splashVerseEnd),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: h * 0.008),
            SlideTransition(
              position: t.refSlide,
              child: FadeTransition(
                opacity: t.refFade,
                child: Text(
                  l.splashVerseReference,
                  style: TextStyle(
                    fontSize: h * 0.020,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
