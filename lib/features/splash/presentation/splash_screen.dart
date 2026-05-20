import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/brand_colors.dart';
import '../../../core/platform_config.dart';
import '../../../injection.dart';
import '../../settings/domain/i_settings_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    // Brand duration is set after the async splash-seen check below.
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bootstrap();
  }

  /// On first launch ever: full 1500ms brand animation. On every launch
  /// after that: short 500ms — the user has already seen the brand reveal.
  Future<void> _bootstrap() async {
    final repo = getIt<ISettingsRepository>();
    final hasSeen = await repo.hasSeenSplash();
    if (!mounted) return;
    _brandController.duration = Duration(milliseconds: hasSeen ? 500 : 1500);
    _fadeOutController.duration =
        Duration(milliseconds: hasSeen ? 200 : 350);
    if (!hasSeen) await repo.markSplashSeen();
    if (!mounted) return;
    _brandController.forward().whenComplete(_fadeAndNavigate);
  }

  void _fadeAndNavigate() async {
    if (!mounted) return;
    String route = '/';
    final isFirst = await getIt<ISettingsRepository>().isFirstLaunch();
    if (isFirst) route = kIsTV ? '/tv_onboarding' : '/onboarding';
    if (!mounted) return;
    _fadeOutController.forward().whenComplete(() {
      if (mounted) Navigator.of(context).pushReplacementNamed(route);
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
                final pulse = (sin(_shimmerController.value * pi * 2) + 1) / 2;
                return Center(
                  child: Container(
                    width: screenH * 0.55,
                    height: screenH * 0.35,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          brandGold.withValues(alpha: 0.04 + pulse * 0.03),
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
