import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a subtle Islamic geometric pattern (5 % opacity) across the screen.
///  • Tiled 8-pointed stars  (two overlapping squares + inner octagon)
///  • Large corner medallions (layered concentric rings + star)
///
/// Paths are pre-built once per unique [Size] and cached as two [Path] objects
/// (tile grid + medallions). This reduces per-frame draw calls from ~576 to 2
/// and avoids cos/sin churn on every repaint.
/// Pair with a [RepaintBoundary] ancestor so [shouldRepaint] returning false
/// actually prevents a repaint (no shared parent layer).
class ArabescPainter extends CustomPainter {
  final Color color;
  final double opacity;

  ArabescPainter({required this.color, this.opacity = 0.05});

  Size? _cachedSize;
  Path? _tilePath;
  Path? _medallionPath;

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedSize != size) {
      _buildPaths(size);
      _cachedSize = size;
    }
    canvas.drawPath(
      _tilePath!,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      _medallionPath!,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.9)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  void _buildPaths(Size size) {
    final tile = Path();
    const cell = 130.0;
    const r = cell * 0.38;
    for (double x = cell / 2; x < size.width + cell; x += cell) {
      for (double y = cell / 2; y < size.height + cell; y += cell) {
        _addStar8(tile, Offset(x, y), r);
      }
    }
    _tilePath = tile;

    final med = Path();
    final m = size.height * 0.44;
    _addMedallion(med, Offset(size.width, 0), m);
    _addMedallion(med, Offset(size.width, size.height), m);
    _addMedallion(med, Offset(0, 0), m * 0.55);
    _addMedallion(med, Offset(0, size.height), m * 0.55);
    _medallionPath = med;
  }

  void _addStar8(Path out, Offset c, double r) {
    _addNgon(out, c, r, 4, 0);
    _addNgon(out, c, r, 4, pi / 4);
    _addNgon(out, c, r * 0.52, 8, pi / 8);
    out.addOval(Rect.fromCircle(center: c, radius: r * 0.09));
  }

  void _addMedallion(Path out, Offset c, double r) {
    out.addOval(Rect.fromCircle(center: c, radius: r));
    out.addOval(Rect.fromCircle(center: c, radius: r * 0.86));
    _addNgon(out, c, r * 0.75, 4, 0);
    _addNgon(out, c, r * 0.75, 4, pi / 4);
    out.addOval(Rect.fromCircle(center: c, radius: r * 0.52));
    _addNgon(out, c, r * 0.44, 8, pi / 8);
    _addNgon(out, c, r * 0.30, 4, 0);
    _addNgon(out, c, r * 0.30, 4, pi / 4);
    out.addOval(Rect.fromCircle(center: c, radius: r * 0.10));
  }

  void _addNgon(Path out, Offset c, double r, int n, double start) {
    for (int i = 0; i < n; i++) {
      final a = start + 2 * pi * i / n;
      final pt = Offset(c.dx + r * cos(a), c.dy + r * sin(a));
      i == 0 ? out.moveTo(pt.dx, pt.dy) : out.lineTo(pt.dx, pt.dy);
    }
    out.close();
  }

  @override
  bool shouldRepaint(ArabescPainter old) =>
      old.color != color || old.opacity != opacity;
}
