import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../prayer/presentation/painters/arabesque_painter.dart';

/// Calm, slowly-shifting dark backdrop for the screensaver: a deep gradient,
/// a drifting accent glow, and a faint arabesque. Driven by a single ambient
/// [animation] (0→1→0) so the whole scene breathes without ever sitting still
/// — which also keeps any one pixel from burning in over long idle hours.
class ScreensaverBackground extends StatelessWidget {
  final Animation<double> animation;
  final AccentPalette palette;

  const ScreensaverBackground({
    super.key,
    required this.animation,
    required this.palette,
  });

  static const Color _base = Color(0xFF05111E);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + t * 0.5, -1),
                end: Alignment(1, 1 - t * 0.5),
                colors: [
                  _base,
                  Color.lerp(_base, palette.primary, 0.16)!,
                  _base,
                ],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment(0.6 - t * 1.2, -0.5 + t * 0.6),
                  child: _Glow(color: palette.primary),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: ArabescPainter(color: Colors.white, opacity: 1),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 1.1,
                        colors: [
                          Colors.transparent,
                          _base.withValues(alpha: 0.55),
                        ],
                        stops: const [0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 700,
        height: 700,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
