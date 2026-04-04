import 'package:flutter/material.dart';

/// Ogee (Islamic pointed) arch clipper for prayer cards.
class IslamicArchClipper extends CustomClipper<Path> {
  /// Fraction of total height devoted to the arch curve.
  final double archRatio;
  final double cornerRadius;

  IslamicArchClipper({this.archRatio = 0.38, this.cornerRadius = 14});

  @override
  Path getClip(Size size) => archPath(size, archRatio, cornerRadius);

  @override
  bool shouldReclip(covariant IslamicArchClipper old) =>
      old.archRatio != archRatio || old.cornerRadius != cornerRadius;

  /// Shared path builder used by both clipper and painter.
  static Path archPath(Size size, double archRatio, double cornerRadius) {
    final w = size.width;
    final h = size.height;
    final archH = h * archRatio;
    final r = cornerRadius;
    final path = Path();

    // Bottom-left corner
    path.moveTo(0, h - r);
    path.quadraticBezierTo(0, h, r, h);

    // Bottom edge -> bottom-right corner
    path.lineTo(w - r, h);
    path.quadraticBezierTo(w, h, w, h - r);

    // Right edge up to where the arch begins
    path.lineTo(w, archH);

    // True Islamic pointed arch: CP near top corners pulls curves strongly inward
    path.quadraticBezierTo(w * 0.92, 0, w / 2, 0); // right half → apex
    path.quadraticBezierTo(w * 0.08, 0, 0, archH); // left half → left edge

    path.close();
    return path;
  }
}

/// Paints the arch fill, border, and shadow behind the clipped content.
class IslamicArchPainter extends CustomPainter {
  final Color? fillColor;
  final Gradient? gradient;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double shadowBlur;
  final double shadowSpread;
  final Offset shadowOffset;
  final double archRatio;
  final double cornerRadius;

  IslamicArchPainter({
    this.fillColor,
    this.gradient,
    required this.borderColor,
    this.borderWidth = 1,
    this.shadowColor = Colors.transparent,
    this.shadowBlur = 0,
    this.shadowSpread = 0,
    this.shadowOffset = Offset.zero,
    this.archRatio = 0.38,
    this.cornerRadius = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = IslamicArchClipper.archPath(size, archRatio, cornerRadius);

    // Shadow
    if (shadowBlur > 0) {
      canvas.drawShadow(path, shadowColor, shadowBlur, false);
    }

    // Fill
    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (gradient != null) {
      fillPaint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      fillPaint.color = fillColor ?? Colors.transparent;
    }
    canvas.drawPath(path, fillPaint);

    // Border
    if (borderWidth > 0 && borderColor != Colors.transparent) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = borderColor
          ..strokeWidth = borderWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant IslamicArchPainter old) =>
      old.fillColor != fillColor ||
      old.gradient != gradient ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.shadowColor != shadowColor ||
      old.shadowBlur != shadowBlur;
}
