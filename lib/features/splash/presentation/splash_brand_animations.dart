import 'package:flutter/material.dart';

/// Pre-built animation curves for [SplashBrandContent].
class SplashBrandAnimations {
  final Animation<double> starFade;
  final Animation<double> titleFade;
  final Animation<double> titleScale;
  final Animation<double> sepScale;
  final Animation<double> verseFade;
  final Animation<Offset> verseSlide;
  final Animation<double> refFade;
  final Animation<Offset> refSlide;

  SplashBrandAnimations(AnimationController brand)
      : starFade = CurvedAnimation(
          parent: brand,
          curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
        ),
        titleFade = CurvedAnimation(
          parent: brand,
          curve: const Interval(0.08, 0.35, curve: Curves.easeOut),
        ),
        titleScale = Tween(begin: 0.75, end: 1.0).animate(CurvedAnimation(
          parent: brand,
          curve: const Interval(0.08, 0.35, curve: Curves.easeOutCubic),
        )),
        sepScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: brand,
          curve: const Interval(0.30, 0.50, curve: Curves.easeInOut),
        )),
        verseFade = CurvedAnimation(
          parent: brand,
          curve: const Interval(0.45, 0.70, curve: Curves.easeOut),
        ),
        verseSlide = Tween(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: brand,
          curve: const Interval(0.45, 0.70, curve: Curves.easeOutCubic),
        )),
        refFade = CurvedAnimation(
          parent: brand,
          curve: const Interval(0.60, 0.80, curve: Curves.easeOut),
        ),
        refSlide = Tween(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: brand,
          curve: const Interval(0.60, 0.80, curve: Curves.easeOutCubic),
        ));
}
