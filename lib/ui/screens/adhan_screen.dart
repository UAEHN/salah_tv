import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../painters/arabesque_painter.dart';

class AdhanScreen extends StatelessWidget {
  final String prayerName;
  final AccentPalette palette;

  const AdhanScreen({
    super.key,
    required this.prayerName,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: ArabescPainter(color: palette.primary, opacity: 0.1),
            ),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    palette.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mosque_rounded,
                  size: 100,
                  color: palette.primary,
                ),
                const SizedBox(height: 30),
                Text(
                  'حان الآن موعد',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'أذان $prayerName',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                    shadows: [
                      Shadow(
                        color: palette.glow,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Skip hint
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: glassDecoration(opacity: 0.05, borderRadius: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stop_circle_outlined, color: kTextMuted, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'اضغط OK لتخطي الأذان',
                        style: TextStyle(
                          fontSize: 20,
                          color: kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
