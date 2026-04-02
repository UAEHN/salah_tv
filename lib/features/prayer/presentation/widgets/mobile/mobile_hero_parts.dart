import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_hero_arc_painter.dart';

/// Circular arc progress ring with prayer icon in the center.
class HeroArcWithIcon extends StatelessWidget {
  final IconData icon;
  final double progress;
  final Color accentBright;
  final Color accentDeep;
  final bool isDark;

  const HeroArcWithIcon({
    super.key,
    required this.icon,
    required this.progress,
    required this.accentBright,
    required this.accentDeep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const ringSize = 72.0;
    const innerSize = 50.0;
    final iconColor = isDark ? accentBright : accentDeep;

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(ringSize),
            painter: HeroArcPainter(
              progress: progress,
              startColor: accentBright.withValues(alpha: 0.6),
              endColor: accentDeep,
              strokeWidth: 4,
              trackColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : accentDeep.withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentBright.withValues(alpha: isDark ? 0.2 : 0.15),
                  accentDeep.withValues(alpha: isDark ? 0.08 : 0.05),
                ],
              ),
              border: Border.all(
                color: accentBright.withValues(alpha: isDark ? 0.2 : 0.25),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}

/// Subtitle text inside a frosted glass pill.
class HeroSubtitlePill extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color accentColor;

  const HeroSubtitlePill({
    super.key,
    required this.text,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : accentColor.withValues(alpha: 0.08),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : accentColor.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        text,
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: isDark
              ? Colors.white.withValues(alpha: 0.75)
              : const Color(0xFF1A103D),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

/// Decorative blurred circle for visual depth.
class HeroGlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const HeroGlowOrb({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size * 0.5, spreadRadius: 4),
        ],
      ),
    );
  }
}
