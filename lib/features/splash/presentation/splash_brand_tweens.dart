import 'package:flutter/material.dart';

/// Pre-computed fade/scale/slide animations driven off the splash brand
/// controller. Bundled so the build method in `splash_brand_content.dart`
/// stays under the 150-line cap and reads as composition rather than setup.
class SplashBrandTweens {
  final Animation<double> starFade;
  final Animation<double> titleFade;
  final Animation<double> titleScale;
  final Animation<double> sepScale;
  final Animation<double> verseFade;
  final Animation<Offset> verseSlide;
  final Animation<double> refFade;
  final Animation<Offset> refSlide;

  SplashBrandTweens._({
    required this.starFade,
    required this.titleFade,
    required this.titleScale,
    required this.sepScale,
    required this.verseFade,
    required this.verseSlide,
    required this.refFade,
    required this.refSlide,
  });

  factory SplashBrandTweens.fromController(AnimationController c) {
    Animation<double> curve(
      double a,
      double b, [
      Curve curve = Curves.easeOut,
    ]) => CurvedAnimation(
      parent: c,
      curve: Interval(a, b, curve: curve),
    );
    final slideTween = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    );
    return SplashBrandTweens._(
      starFade: curve(0.0, 0.25),
      titleFade: curve(0.08, 0.35),
      titleScale: Tween(
        begin: 0.75,
        end: 1.0,
      ).animate(curve(0.08, 0.35, Curves.easeOutCubic)),
      sepScale: Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(curve(0.30, 0.50, Curves.easeInOut)),
      verseFade: curve(0.45, 0.70),
      verseSlide: slideTween.animate(curve(0.45, 0.70, Curves.easeOutCubic)),
      refFade: curve(0.60, 0.80),
      refSlide: slideTween.animate(curve(0.60, 0.80, Curves.easeOutCubic)),
    );
  }
}
