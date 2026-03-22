import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/mobile_theme.dart';
import '../../../../core/widgets/mobile/mobile_bottom_nav.dart';
import '../widgets/mobile/mobile_settings_list.dart';

class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/');
      },
      child: Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Gradient background — matches home screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 2. Ambient orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.secondary.withValues(
                  alpha: MobileColors.isDark(context) ? 0.07 : 0.10,
                ),
              ),
            ),
          ),

          // 3. Blur to blend orbs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          // 4. Content
          const SafeArea(bottom: false, child: MobileSettingsList()),

          // 5. Floating Bottom Navigation
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MobileBottomNav(currentIndex: 0),
          ),
        ],
      ),
    ),
    );
  }
}
