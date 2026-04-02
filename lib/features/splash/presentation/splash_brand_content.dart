import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../core/brand_colors.dart';

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

    final starFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    final titleFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.08, 0.35, curve: Curves.easeOut),
    );
    final titleScale = Tween(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: brandAnimation,
        curve: const Interval(0.08, 0.35, curve: Curves.easeOutCubic),
      ),
    );
    final sepScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: brandAnimation,
        curve: const Interval(0.30, 0.50, curve: Curves.easeInOut),
      ),
    );
    final verseFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.45, 0.70, curve: Curves.easeOut),
    );
    final verseSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: brandAnimation,
            curve: const Interval(0.45, 0.70, curve: Curves.easeOutCubic),
          ),
        );
    final refFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.60, 0.80, curve: Curves.easeOut),
    );
    final refSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: brandAnimation,
            curve: const Interval(0.60, 0.80, curve: Curves.easeOutCubic),
          ),
        );

    return AnimatedBuilder(
      animation: Listenable.merge([brandAnimation, shimmerAnimation]),
      builder: (_, _) {
        final pulse = (sin(shimmerAnimation.value * pi * 2) + 1) / 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✦ ornament — pulsing glow
            FadeTransition(
              opacity: starFade,
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
            // App title with shimmer + glow
            FadeTransition(
              opacity: titleFade,
              child: ScaleTransition(
                scale: titleScale,
                child: SizedBox(
                  width: w * 0.85,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _shimmerTitle(h, l.appTitle),
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),
            // ── golden separator ──
            Transform.scale(
              scaleX: sepScale.value,
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
            // Quranic verse — fade + slide up
            SlideTransition(
              position: verseSlide,
              child: FadeTransition(
                opacity: verseFade,
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
            // Surah reference — fade + slide up
            SlideTransition(
              position: refSlide,
              child: FadeTransition(
                opacity: refFade,
                child: Text(
                  l.splashVerseReference,
                  style: TextStyle(fontSize: h * 0.020, color: Colors.white38),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shimmerTitle(double h, String title) {
    final center = shimmerAnimation.value * 1.6 - 0.3;
    final style = TextStyle(
      fontSize: h * 0.13,
      fontWeight: FontWeight.w700,
      letterSpacing: 8,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow layer behind
        Text(
          title,
          style: style.copyWith(
            color: brandGold.withValues(alpha: 0.25),
            shadows: [
              Shadow(color: brandGold.withValues(alpha: 0.4), blurRadius: 40),
            ],
          ),
        ),
        // Shimmer layer on top
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [brandGold, brandGoldLight, brandGold],
            stops: [
              (center - 0.15).clamp(0.0, 1.0),
              center.clamp(0.0, 1.0),
              (center + 0.15).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: Text(title, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
