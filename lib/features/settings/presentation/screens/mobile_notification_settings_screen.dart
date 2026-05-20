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

          // Content
          const SafeArea(child: MobileNotificationSettingsList()),
        ],
      ),
    );
  }
}
