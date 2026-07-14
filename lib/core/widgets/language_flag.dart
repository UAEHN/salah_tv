import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Small national-flag badge for a UI language, drawn from a bundled SVG.
///
/// Deliberately NOT a flag emoji — Android TV boxes render flag emoji as bare
/// letter pairs (e.g. "FR"), so real vector flags are bundled in
/// `assets/flags/`. Maps each app locale to a representative country flag;
/// falls back to a translate glyph for an unmapped locale.
class LanguageFlag extends StatelessWidget {
  final String locale;

  /// Flag height in logical pixels; width follows the 3:2 flag ratio.
  final double height;

  const LanguageFlag({super.key, required this.locale, this.height = 24});

  // Arabic → Saudi Arabia (common convention for the Arabic language),
  // English → United Kingdom, French → France.
  static const _flagAsset = {
    'ar': 'assets/flags/sa.svg',
    'en': 'assets/flags/gb.svg',
    'fr': 'assets/flags/fr.svg',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _flagAsset[locale];
    if (asset == null) {
      return Icon(Icons.translate_rounded, size: height, color: Colors.white70);
    }
    return Container(
      width: height * 1.5,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: SvgPicture.asset(asset, fit: BoxFit.cover),
    );
  }
}
