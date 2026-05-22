import 'package:flutter/material.dart';

/// Custom background for the notification onboarding. Deliberately calm:
/// a clean dark gradient with a single warm radial glow behind the hero —
/// no stars, no particles, no competing layers. Lets the typography and the
/// permission list do the talking.
class NotificationOnboardingBackground extends StatelessWidget {
  const NotificationOnboardingBackground({super.key});

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
              colors: [
                Color(0xFF0F1729),
                Color(0xFF080C1A),
                Color(0xFF04060D),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -size.height * 0.15,
          left: -size.width * 0.20,
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
          right: -size.width * 0.30,
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
