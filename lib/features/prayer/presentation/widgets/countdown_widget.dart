import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/presentation/settings_provider.dart';

class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    // Pre-blended solid tint instead of a two-stop semi-transparent gradient
    // (which choked the TV GPU on cheaper devices — see §7). Same visual
    // weight as the old gradient midpoint, ~16% palette primary over surface.
    final hintFill = Color.alphaBlend(
      palette.primary.withValues(alpha: 0.16),
      tc.bgSurface,
    );

    return Container(
      width: screenW,
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.03,
        vertical: screenH * 0.015,
      ),
      decoration: BoxDecoration(
        color: hintFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenH * 0.015,
              vertical: screenH * 0.006,
            ),
            decoration: BoxDecoration(
              color: tc.textMuted.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tc.textMuted.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_remote,
                  color: tc.textMuted,
                  size: screenH * 0.022,
                ),
                SizedBox(width: screenW * 0.005),
                Text(
                  l.pressOkForSettings,
                  style: TextStyle(
                    fontSize: screenH * 0.022,
                    color: tc.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
