import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);

/// Small art-deco ornament shown above the app title: thin gold lines
/// flanking a rotated diamond glyph. Replaces the old pulsing ✦ star.
class SplashOrnament extends StatelessWidget {
  const SplashOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _OrnamentLine(),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(1),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.55),
                blurRadius: 8,
              ),
            ],
          ),
          transform: Matrix4.rotationZ(0.785398),
          transformAlignment: Alignment.center,
        ),
        const SizedBox(width: 10),
        const _OrnamentLine(reverse: true),
      ],
    );
  }
}

class _OrnamentLine extends StatelessWidget {
  final bool reverse;
  const _OrnamentLine({this.reverse = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
          end: reverse ? Alignment.centerLeft : Alignment.centerRight,
          colors: [Colors.transparent, _accent.withValues(alpha: 0.65)],
        ),
      ),
    );
  }
}
