import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import 'splash_brand_tweens.dart';
import 'splash_brand_typography.dart';
import 'splash_ornament.dart';

const _accent = Color(0xFFE6B450);

/// Center brand stack: ornament, app title, thin separator, verse,
/// reference. Each layer fades and slides on a staggered timeline driven
/// by [SplashBrandTweens].
class SplashBrandContent extends StatelessWidget {
  final AnimationController brandAnimation;

  const SplashBrandContent({required this.brandAnimation, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    final t = SplashBrandTweens.fromController(brandAnimation);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(opacity: t.starFade, child: const SplashOrnament()),
        SizedBox(height: h * 0.020),
        FadeTransition(
          opacity: t.titleFade,
          child: ScaleTransition(
            scale: t.titleScale,
            child: SizedBox(
              width: w * 0.85,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SplashTitle(text: l.appTitle, height: h),
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.020),
        ScaleTransition(
          scale: t.sepScale,
          alignment: Alignment.center,
          child: Container(
            width: h * 0.30,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _accent, Colors.transparent],
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.028),
        SlideTransition(
          position: t.verseSlide,
          child: FadeTransition(
            opacity: t.verseFade,
            child: SplashVerse(
              start: l.splashVerseStart,
              highlight: l.splashVerseHighlight,
              end: l.splashVerseEnd,
              height: h,
            ),
          ),
        ),
        SizedBox(height: h * 0.012),
        SlideTransition(
          position: t.refSlide,
          child: FadeTransition(
            opacity: t.refFade,
            child: Text(
              l.splashVerseReference,
              style: TextStyle(
                fontSize: h * 0.018,
                color: Colors.white.withValues(alpha: 0.40),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
