import 'dart:math';
import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4A843);
const _kGoldLight = Color(0xFFF5D78E);

/// Centre content: pulsing ✦ ornament, "غسق" with golden shimmer + glow,
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
    final h = MediaQuery.of(context).size.height;

    final starFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    final titleFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.08, 0.35, curve: Curves.easeOut),
    );
    final titleScale = Tween(begin: 0.75, end: 1.0).animate(CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.08, 0.35, curve: Curves.easeOutCubic),
    ));
    final sepScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.30, 0.50, curve: Curves.easeInOut),
    ));
    final verseFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.45, 0.70, curve: Curves.easeOut),
    );
    final verseSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.45, 0.70, curve: Curves.easeOutCubic),
    ));
    final refFade = CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.60, 0.80, curve: Curves.easeOut),
    );
    final refSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: brandAnimation,
      curve: const Interval(0.60, 0.80, curve: Curves.easeOutCubic),
    ));

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
                    color: _kGold,
                    shadows: [
                      Shadow(
                        color: _kGold.withValues(alpha: 0.3 + pulse * 0.5),
                        blurRadius: 8 + pulse * 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.015),
            // غسق — shimmer + glow
            FadeTransition(
              opacity: titleFade,
              child: ScaleTransition(
                scale: titleScale,
                child: _shimmerTitle(h),
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
                    colors: [Colors.transparent, _kGold, Colors.transparent],
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
                    children: const [
                      TextSpan(text: 'أَقِمِ ٱلصَّلَوٰةَ لِدُلُوكِ ٱلشَّمْسِ إِلَىٰ '),
                      TextSpan(
                        text: 'غَسَقِ',
                        style: TextStyle(
                          color: _kGold,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: _kGold, blurRadius: 12),
                          ],
                        ),
                      ),
                      TextSpan(text: ' ٱلَّيْلِ'),
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
                  'الإسراء: ٧٨',
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

  Widget _shimmerTitle(double h) {
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
          'غسق',
          style: style.copyWith(
            color: _kGold.withValues(alpha: 0.25),
            shadows: [Shadow(color: _kGold.withValues(alpha: 0.4), blurRadius: 40)],
          ),
        ),
        // Shimmer layer on top
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [_kGold, _kGoldLight, _kGold],
            stops: [
              (center - 0.15).clamp(0.0, 1.0),
              center.clamp(0.0, 1.0),
              (center + 0.15).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: Text('غسق', style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
