import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_floating_orb.dart';

class MobileHomeBackground extends StatelessWidget {
  const MobileHomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);
    final isDark = MobileColors.isDark(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        MobileFloatingOrb(
          size: 280,
          color: MobileColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
          initialAlignment: const Alignment(1.8, -0.9),
          delaySeconds: 0,
        ),
        MobileFloatingOrb(
          size: 320,
          color: MobileColors.secondary.withValues(alpha: isDark ? 0.06 : 0.04),
          initialAlignment: const Alignment(-1.5, 0.8),
          delaySeconds: 2,
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
}
