import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a subtle Islamic geometric pattern (5 % opacity) across the screen.
///  • Tiled 8-pointed stars  (two overlapping squares + inner octagon)
///  • Large corner medallions (layered concentric rings + star)
class ArabescPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const ArabescPainter({required this.color, this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ── Tiled 8-pointed star grid ─────────────────────────────────────────
    const cell = 130.0;
    const r    = cell * 0.38;
    for (double x = cell / 2; x < size.width  + cell; x += cell) {
      for (double y = cell / 2; y < size.height + cell; y += cell) {
        _star8(canvas, linePaint, Offset(x, y), r);
      }
    }

    // ── Corner medallions ─────────────────────────────────────────────────
    final medPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.9)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final med = size.height * 0.44;
    _medallion(canvas, medPaint, Offset(size.width, 0),           med);
    _medallion(canvas, medPaint, Offset(size.width, size.height), med);
    _medallion(canvas, medPaint, Offset(0, 0),                    med * 0.55);
    _medallion(canvas, medPaint, Offset(0, size.height),          med * 0.55);
  }

  void _star8(Canvas canvas, Paint p, Offset c, double r) {
    _ngon(canvas, p, c, r,        4, 0);       // upright square
    _ngon(canvas, p, c, r,        4, pi / 4);  // rotated 45 °
    _ngon(canvas, p, c, r * 0.52, 8, pi / 8); // inner octagon
    canvas.drawCircle(c, r * 0.09, p);         // centre dot
  }

  void _medallion(Canvas canvas, Paint p, Offset c, double r) {
    canvas.drawCircle(c, r,        p);
    canvas.drawCircle(c, r * 0.86, p);
    _ngon(canvas, p, c, r * 0.75, 4, 0);
    _ngon(canvas, p, c, r * 0.75, 4, pi / 4);
    canvas.drawCircle(c, r * 0.52, p);
    _ngon(canvas, p, c, r * 0.44, 8, pi / 8);
    _ngon(canvas, p, c, r * 0.30, 4, 0);
    _ngon(canvas, p, c, r * 0.30, 4, pi / 4);
    canvas.drawCircle(c, r * 0.10, p);
  }

  void _ngon(Canvas canvas, Paint p, Offset c, double r, int n, double start) {
    final path = Path();
    for (int i = 0; i < n; i++) {
      final a  = start + 2 * pi * i / n;
      final pt = Offset(c.dx + r * cos(a), c.dy + r * sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(ArabescPainter old) =>
      old.color != color || old.opacity != opacity;
}
