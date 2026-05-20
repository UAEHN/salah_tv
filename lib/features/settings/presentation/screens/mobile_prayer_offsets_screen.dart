import 'package:flutter/material.dart';
import '../../../../core/mobile_theme.dart';
import '../widgets/mobile/mobile_prayer_offsets_list.dart';

class MobilePrayerOffsetsScreen extends StatelessWidget {
  const MobilePrayerOffsetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
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
          const SafeArea(child: MobilePrayerOffsetsList()),
        ],
      ),
    );
  }
}
