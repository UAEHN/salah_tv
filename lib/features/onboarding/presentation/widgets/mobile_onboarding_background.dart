import 'package:flutter/material.dart';

/// Calm dark background for the mobile onboarding flow. Two soft radial
/// glows on a vertical gradient — no animated stars or particles, so the
/// content can breathe.
class MobileOnboardingBackground extends StatelessWidget {
  const MobileOnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F1729), Color(0xFF080C1A), Color(0xFF04060D)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -size.height * 0.15,
          right: -size.width * 0.20,
          child: IgnorePointer(
            child: Container(
              width: size.width * 1.1,
              height: size.width * 1.1,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x33E6B450), Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.10,
          left: -size.width * 0.30,
          child: IgnorePointer(
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x1A3B6FE6), Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
