import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

class MobileThemeDialog extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onSave;

  const MobileThemeDialog({
    super.key,
    required this.isDarkMode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cardColor = MobileColors.cardColor(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: MobileColors.border(context))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MobileColors.onSurfaceMuted(
                  context,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.settingsCustomizeAppearance,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: MobileColors.onSurface(context), fontSize: 18),
            ),
            const SizedBox(height: 24),
            MobileSelectOptionTile(
              title: l.settingsDarkMode,
              icon: Icons.dark_mode_rounded,
              isSelected: isDarkMode,
              onTap: () {
                onSave(true);
                Navigator.pop(context);
              },
            ),
            MobileSelectOptionTile(
              title: l.settingsLightMode,
              icon: Icons.light_mode_rounded,
              isSelected: !isDarkMode,
              onTap: () {
                onSave(false);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
