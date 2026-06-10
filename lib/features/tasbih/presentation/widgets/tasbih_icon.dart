import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the bundled `assets/tasbih.svg` as a single-colour
/// pictogram. A [ColorFilter.mode] with [BlendMode.srcIn] overrides
/// every fill in the source SVG with the caller's [color], so the
/// glyph picks up the active theme's accent without us shipping
/// per-theme SVG variants.
///
/// Drop-in replacement for `Icon(IconData, size: , color: )` — the
/// API matches deliberately so call-sites read the same.
class TasbihIcon extends StatelessWidget {
  static const String _asset = 'assets/tasbih.svg';

  final double size;
  final Color color;

  const TasbihIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
