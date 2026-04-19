import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Static gradient background for the mobile home screen.
/// Previously used BackdropFilter(blur σ=60) + two animated orbs,
/// which caused continuous GPU load and device heat.
/// Replaced with a simple two-stop gradient — visually equivalent at mobile sizes.
class MobileHomeBackground extends StatelessWidget {
  const MobileHomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}
