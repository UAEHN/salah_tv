import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';
import '../../domain/constants/customization_constants.dart';
import '../../domain/entities/quran_font_info.dart';
import 'selected_check_badge.dart';

/// Tappable preview tile rendering a font family with an Arabic sample so
/// the user can compare typefaces visually before committing.
class FontPreviewCard extends StatelessWidget {
  final QuranFontInfo font;
  final String labelText;
  final String hintText;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const FontPreviewCard({
    super.key,
    required this.font,
    required this.labelText,
    required this.hintText,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: MobileColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? MobileColors.activePrimary(context)
                    : MobileColors.border(context),
                width: isSelected ? 2.4 : 1,
              ),
              boxShadow: MobileShadows.sleekCard(context),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelText,
                      style: MobileTextStyles.headlineMd(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hintText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        hintText,
                        style: MobileTextStyles.labelSm(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        kFontSampleArabic,
                        style: TextStyle(
                          fontFamily: font.id,
                          fontSize: 24,
                          height: 1.6,
                          color: MobileColors.onSurface(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
