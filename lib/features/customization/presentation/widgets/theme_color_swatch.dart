import 'package:flutter/material.dart';

/// Two stacked color circles representing a palette's primary/secondary
/// pair. Pure presentation — no logic, no state.
class ThemeColorSwatch extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final double size;

  const ThemeColorSwatch({
    super.key,
    required this.primary,
    required this.secondary,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final overlap = size * 0.55;
    return SizedBox(
      width: size + overlap,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _Dot(color: primary, size: size),
          ),
          Positioned(
            left: overlap,
            top: 0,
            child: _Dot(color: secondary, size: size),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
