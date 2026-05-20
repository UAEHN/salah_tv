import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../domain/entities/theme_palette_info.dart';
import '../logic/customization_l10n_resolver.dart';
import 'theme_preview_card.dart';

/// Two-column grid of theme palettes, presented as a single unified list.
class ThemePickerGrid extends StatelessWidget {
  final List<ThemePaletteInfo> palettes;
  final String selectedId;
  final bool isLocked;
  final ValueChanged<String> onPick;

  const ThemePickerGrid({
    super.key,
    required this.palettes,
    required this.selectedId,
    required this.isLocked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: palettes.length,
      itemBuilder: (context, index) {
        final palette = palettes[index];
        return ThemePreviewCard(
          palette: palette,
          labelText: resolveThemeLabel(l, palette.labelKey),
          isSelected: palette.id == selectedId,
          isLocked: isLocked,
          onTap: () => onPick(palette.id),
        );
      },
    );
  }
}
