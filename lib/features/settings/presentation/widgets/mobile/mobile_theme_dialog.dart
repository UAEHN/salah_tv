import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

/// Brightness picker: light / dark / system. Stored as a `themeMode` string
/// in `AppSettings` so the app can honor the device theme automatically.
class MobileThemeDialog extends StatelessWidget {
  final String currentMode; // 'system' | 'light' | 'dark'
  final ValueChanged<String> onSave;

  const MobileThemeDialog({
    super.key,
    required this.currentMode,
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
              title: l.settingsSystemMode,
              icon: Icons.brightness_auto_rounded,
              isSelected: currentMode == 'system',
              onTap: () {
                onSave('system');
                Navigator.pop(context);
              },
            ),
            MobileSelectOptionTile(
              title: l.settingsLightMode,
              icon: Icons.light_mode_rounded,
              isSelected: currentMode == 'light',
              onTap: () {
                onSave('light');
                Navigator.pop(context);
              },
            ),
            MobileSelectOptionTile(
              title: l.settingsDarkMode,
              icon: Icons.dark_mode_rounded,
              isSelected: currentMode == 'dark',
              onTap: () {
                onSave('dark');
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
