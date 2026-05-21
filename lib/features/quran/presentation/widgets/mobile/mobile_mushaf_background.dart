import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Plain theme-aware gradient backdrop for the Mushaf landing screen.
/// No decorative blobs — kept minimal at the user's request so the
/// surah list reads against a calm background.
class MobileMushafBackground extends StatelessWidget {
  const MobileMushafBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: MobileColors.homeGradient(context),
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }
}
