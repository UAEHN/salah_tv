import 'package:flutter/material.dart';

import '../../../core/platform_config.dart';
import '../../../injection.dart';
import '../../settings/domain/i_settings_repository.dart';
import 'splash_brand_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _brandController;
  late final AnimationController _fadeOutController;

  @override
  void initState() {
    super.initState();
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _bootstrap();
  }

  /// First launch ever: full 1300ms reveal. Every launch after: short
  /// 480ms — the user has already seen the brand.
  Future<void> _bootstrap() async {
    final repo = getIt<ISettingsRepository>();
    final hasSeen = await repo.hasSeenSplash();
    if (!mounted) return;
    _brandController.duration = Duration(milliseconds: hasSeen ? 480 : 1300);
    _fadeOutController.duration = Duration(milliseconds: hasSeen ? 200 : 320);
    if (!hasSeen) await repo.markSplashSeen();
    if (!mounted) return;
    _brandController.forward().whenComplete(_fadeAndNavigate);
  }

  Future<void> _fadeAndNavigate() async {
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
    _brandController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF04060D),
      body: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
        ),
        child: Stack(
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
              top: size.height * 0.22,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  width: size.width,
                  height: size.width * 0.9,
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
            Center(child: SplashBrandContent(brandAnimation: _brandController)),
          ],
        ),
      ),
    );
  }
}
