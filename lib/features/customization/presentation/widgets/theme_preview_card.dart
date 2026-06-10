import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';
import '../../domain/entities/theme_palette_info.dart';
import 'selected_check_badge.dart';
import 'theme_color_swatch.dart';

/// Tappable preview card for a single theme palette.
/// Resolves the palette label via [labelText] (already localized by caller).
class ThemePreviewCard extends StatelessWidget {
  final ThemePaletteInfo palette;
  final String labelText;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.palette,
    required this.labelText,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Color(palette.primaryArgb);
    final secondary = Color(palette.secondaryArgb);

    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MobileColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primary : MobileColors.border(context),
                width: isSelected ? 2.4 : 1,
              ),
              boxShadow: MobileShadows.sleekCard(context),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [primary, secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: ThemeColorSwatch(
                        primary: primary,
                        secondary: secondary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      labelText,
                      style: MobileTextStyles.headlineMd(
                        context,
                      ).copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: SelectedCheckBadge(isVisible: isSelected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
