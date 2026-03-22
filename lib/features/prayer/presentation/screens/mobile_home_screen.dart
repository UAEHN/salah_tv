import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/mobile_theme.dart';
import '../../../../core/widgets/mobile/mobile_bottom_nav.dart';
import '../widgets/mobile/mobile_top_bar.dart';
import '../widgets/mobile/mobile_hero_card.dart';
import '../widgets/mobile/mobile_prayer_list.dart';

/// Mobile home screen — "Modern Oasis" dark design.
/// PrayerBloc drives all state; build() is side-effect-free.
class MobileHomeScreen extends StatelessWidget {
  final String city;
  final String country;
  final bool is24HourFormat;

  const MobileHomeScreen({
    super.key,
    required this.city,
    required this.country,
    required this.is24HourFormat,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return Scaffold(
      extendBody: true, // Allow content to flow behind floating nav bar
      body: Stack(
        children: [
          // 1. Deep elegant gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 2. Ambient glowing orbs (Mesh Gradient feel)
          Positioned(
            top: -100,
            left: -50,
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
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.primaryContainer.withValues(
                  alpha: MobileColors.isDark(context) ? 0.08 : 0.12,
                ),
              ),
            ),
          ),

          // 3. Heavy blur layer to blend the orbs smoothly into the background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          // 4. Main Content
          SafeArea(
            bottom: false, // Handle bottom spacing manually due to floating nav
            child: Column(
              children: [
                MobileTopBar(city: city, country: country),
                const SizedBox(height: 16),
                const MobileHeroCard(),
                const SizedBox(height: 32),
                Expanded(
                  child: MobilePrayerList(is24HourFormat: is24HourFormat),
                ),
                const SizedBox(height: 100), // Space for floating nav bar
              ],
            ),
          ),

          // 5. Floating Bottom Navigation
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MobileBottomNav(),
          ),
        ],
      ),
    );
  }
}
