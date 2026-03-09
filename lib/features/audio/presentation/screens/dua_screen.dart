import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../prayer/presentation/painters/arabesque_painter.dart';

class DuaScreen extends StatelessWidget {
  final AccentPalette palette;

  const DuaScreen({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background arabesque pattern
          Positioned.fill(
            child: CustomPaint(
              painter: ArabescPainter(color: palette.primary, opacity: 0.08),
            ),
          ),

          // Radial gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    palette.primary.withValues(alpha: 0.07),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Top decorative bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 6,
              decoration: BoxDecoration(gradient: palette.gradient),
            ),
          ),

          // Bottom decorative bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 6,
              decoration: BoxDecoration(gradient: palette.gradient),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: palette.primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: palette.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Label
                  Text(
                    'دعاء بعد الأذان',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: kTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: palette.gradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Dua text
                  Text(
                    'اللهم ربَّ هذه الدعوةِ التامة، والصلاةِ القائمة،\n'
                    'آتِ محمدًا الوسيلةَ والفضيلة، وابعَثْه مقامًا محمودًا الذي وعَدْتَه',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: palette.primary,
                      height: 1.8,
                      shadows: [
                        Shadow(
                          color: palette.glow,
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
