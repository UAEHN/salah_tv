import 'package:flutter/material.dart';

import '../../../splash/presentation/splash_particles.dart';
import '../../../splash/presentation/splash_star_field.dart';

const _bgTop = Color(0xFF050A18);
const _bgBottom = Color(0xFF0F1B33);
class OnboardingBackground extends StatelessWidget {
  final Animation<double> starsAnimation;

  const OnboardingBackground({super.key, required this.starsAnimation});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgTop, _bgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -screenH * 0.05,
          right: screenH * 0.15,
          child: Container(
            width: screenH * 0.5,
            height: screenH * 0.5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x0ED4A843), Colors.transparent],
              ),
            ),
          ),
        ),
        SplashStarField(animation: starsAnimation),
        SplashParticles(animation: starsAnimation),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.transparent, Color(0x55000000)],
              radius: 1.2,
              stops: [0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
