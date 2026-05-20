import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';

/// Visual sibling to [QuranButtonFace] — same pill shape, border, and focus
/// ring so the two buttons read as a balanced pair, but with a distinct
/// celebration icon and label. Stays theme-aware via [ThemeColors] and the
/// active [AccentPalette].
class TakbeeratButtonFace extends StatelessWidget {
  const TakbeeratButtonFace({
    super.key,
    required this.palette,
    required this.isDarkMode,
    required this.isPlaying,
    required this.isFocused,
  });

  final AccentPalette palette;
  final bool isDarkMode;
  final bool isPlaying;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final borderAlpha = isPlaying ? 0.85 : 0.55;
    final innerColor = isPlaying
        ? (isDarkMode
            ? Colors.black.withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.75))
        : (isDarkMode
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.07));
    final textColor = isDarkMode
        ? Colors.white.withValues(alpha: isPlaying ? 1 : 0.92)
        : kTextPrimary.withValues(alpha: isPlaying ? 1 : 0.88);
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: palette.primary.withValues(alpha: borderAlpha),
        border: isFocused
            ? Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.9)
                    : kTextPrimary.withValues(alpha: 0.85),
                width: 2,
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.5),
          color: innerColor,
        ),
        child: Text(
          l.takbeeratButtonLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w600,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
