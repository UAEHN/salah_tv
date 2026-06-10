import 'package:flutter/material.dart';

import 'classic_visuals.dart';

/// Shared "mosque display" countdown card chrome: a gold-tinted gradient panel
/// with an eyebrow line and a large countdown. Both the next-prayer and iqama
/// countdowns render through it (§4 DRY) so the card styling lives in one place.
class ClassicCountCard extends StatelessWidget {
  final ClassicVisuals vis;
  final Widget eyebrow;
  final Widget big;

  const ClassicCountCard({
    super.key,
    required this.vis,
    required this.eyebrow,
    required this.big,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenW * 0.45),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.034,
          vertical: screenH * 0.040,
        ),
        decoration: BoxDecoration(
          gradient: vis.countCardGradient,
          border: Border.all(color: vis.countCardBorder, width: 1.2),
          borderRadius: BorderRadius.circular(30),
          boxShadow: vis.countCardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            eyebrow,
            SizedBox(height: screenH * 0.020),
            // Scale the countdown down if it would overflow the card width
            // (e.g. a long HH:MM:SS on a narrow window).
            FittedBox(fit: BoxFit.scaleDown, child: big),
          ],
        ),
      ),
    );
  }
}
