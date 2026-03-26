import 'dart:math';
import 'package:flutter/material.dart';
import 'splash_star_field.dart';
import 'splash_particles.dart';
import 'splash_brand_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _starsController;
  late final AnimationController _brandController;
  late final AnimationController _shimmerController;
  late final AnimationController _fadeOutController;

  static const _bgTop = Color(0xFF050A18);
  static const _bgBottom = Color(0xFF0F1B33);
  static const _kGold = Color(0xFFD4A843);

  @override
  void initState() {
    super.initState();
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..forward().whenComplete(_fadeAndNavigate);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _fadeAndNavigate() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _fadeOutController.forward().whenComplete(() {
        if (mounted) Navigator.of(context).pushReplacementNamed('/');
      });
    });
  }

  @override
  void dispose() {
    _starsController.dispose();
    _brandController.dispose();
    _shimmerController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _bgTop,
      body: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Deep night gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bgTop, _bgBottom],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Subtle golden glow — distant moonlight
            Positioned(
              top: -screenH * 0.08,
              right: screenH * 0.2,
              child: Container(
                width: screenH * 0.55,
                height: screenH * 0.55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x12D4A843), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Twinkling stars + shooting stars
            SplashStarField(animation: _starsController),
            // Golden particles drifting up
            SplashParticles(animation: _starsController),
            // Pulsing glow behind title
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, _) {
                final pulse =
                    (sin(_shimmerController.value * pi * 2) + 1) / 2;
                return Center(
                  child: Container(
                    width: screenH * 0.55,
                    height: screenH * 0.35,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _kGold.withValues(alpha: 0.04 + pulse * 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Cinematic vignette
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.transparent, Color(0x66000000)],
                  radius: 1.2,
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            // Brand content
            Center(
              child: SplashBrandContent(
                brandAnimation: _brandController,
                shimmerAnimation: _shimmerController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
