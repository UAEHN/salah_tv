import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class QuranButtonFace extends StatelessWidget {
  final AccentPalette palette;
  final bool isDarkMode;
  final bool isPlaying;
  final bool isPausedForAdhan;
  final bool isFocused;
  final double angle;
  final double fadeT;

  const QuranButtonFace({
    super.key,
    required this.palette,
    required this.isDarkMode,
    required this.isPlaying,
    required this.isPausedForAdhan,
    required this.isFocused,
    required this.angle,
    required this.fadeT,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin(angle * 2) + 1) / 2;
    final t = fadeT;
    final a0 = 0.45 + (0.65 - 0.45) * t;
    final a1 = 0.70 + (0.95 - 0.70) * t;
    final shadowAlpha = (0.25 + pulse * 0.35) * t;
    final blurR = (10 + pulse * 8) * t;
    final spreadR = (pulse * 1.5) * t;
    final idleInner = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);
    final playingInner = isDarkMode
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.75);
    final innerColor = Color.lerp(idleInner, playingInner, t)!;
    final textColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.92 + 0.08 * t)
        : kTextPrimary.withValues(alpha: 0.88 + 0.12 * t);
    final idleIconColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.85)
        : kTextPrimary.withValues(alpha: 0.80);
    final iconColor = Color.lerp(
      idleIconColor,
      isDarkMode ? palette.primary : palette.secondary,
      t,
    )!;
    final textShadow = t > 0.05
        ? Shadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.6 * t)
                : Colors.white.withValues(alpha: 0.7 * t),
            blurRadius: 6 * t,
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: SweepGradient(
          startAngle: angle,
          endAngle: angle + 2 * math.pi,
          colors: [
            palette.primary.withValues(alpha: a0),
            palette.primary.withValues(alpha: a1),
            palette.primary.withValues(alpha: a0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: isFocused
            ? Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.9)
                    : kTextPrimary.withValues(alpha: 0.85),
                width: 2,
              )
            : null,
        boxShadow: shadowAlpha > 0.01
            ? [
                BoxShadow(
                  color: palette.glow.withValues(alpha: shadowAlpha),
                  blurRadius: blurR,
                  spreadRadius: spreadR,
                ),
              ]
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.5),
          color: innerColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isPlaying),
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'القرآن الكريم',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.lerp(FontWeight.w600, FontWeight.w700, t) ??
                    FontWeight.w600,
                color: textColor,
                letterSpacing: 0.5,
                shadows: textShadow != null ? [textShadow] : null,
              ),
            ),
            if (isPausedForAdhan) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.pause_circle_outline_rounded,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.90),
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
