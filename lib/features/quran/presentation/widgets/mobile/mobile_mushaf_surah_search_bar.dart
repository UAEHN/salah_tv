import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';

/// Search field shown above the surah index on the Mushaf landing screen.
/// Filters by Arabic surah name with substring match (no diacritics
/// normalisation needed because `kSurahs` names are stored unvocalised).
class MobileMushafSurahSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MobileMushafSurahSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: MobileColors.cardColor(context).withValues(
          alpha: isDark ? 0.55 : 0.85,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MobileColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: MobileColors.onSurfaceFaint(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.search,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurface(context),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: AppLocalizations.of(context).mushafSearchHint,
                hintStyle: MobileTextStyles.bodyMd(context),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: MobileColors.onSurfaceFaint(context),
              ),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
