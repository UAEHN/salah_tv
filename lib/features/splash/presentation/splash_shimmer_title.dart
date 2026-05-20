import 'package:flutter/material.dart';

import '../../../core/brand_colors.dart';

/// Two-layer title used in the splash screen:
/// a soft gold glow underneath and a shimmer-swept gradient on top.
class SplashShimmerTitle extends StatelessWidget {
  final double height;
  final String title;
  final double shimmerValue;

  const SplashShimmerTitle({
    required this.height,
    required this.title,
    required this.shimmerValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final center = shimmerValue * 1.6 - 0.3;
    final style = TextStyle(
      fontSize: height * 0.13,
      fontWeight: FontWeight.w700,
      letterSpacing: 8,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          title,
          style: style.copyWith(
            color: brandGold.withValues(alpha: 0.25),
            shadows: [
              Shadow(color: brandGold.withValues(alpha: 0.4), blurRadius: 40),
            ],
          ),
        ),
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
