import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/mobile_theme.dart';
import '../widgets/mobile/mobile_notification_settings_list.dart';

class MobileNotificationSettingsScreen extends StatelessWidget {
  const MobileNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Gradient background
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

          // Ambient orbs
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

          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          // Content
          const SafeArea(child: MobileNotificationSettingsList()),
        ],
      ),
    );
  }
}
