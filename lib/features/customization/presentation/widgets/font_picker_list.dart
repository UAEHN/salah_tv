import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../domain/entities/quran_font_info.dart';
import '../logic/customization_l10n_resolver.dart';
import 'font_preview_card.dart';

class FontPickerList extends StatelessWidget {
  final List<QuranFontInfo> fonts;
  final String selectedFamily;
  final bool isLocked;
  final ValueChanged<String> onPick;

  const FontPickerList({
    super.key,
    required this.fonts,
    required this.selectedFamily,
    required this.isLocked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: fonts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final font = fonts[index];
        return FontPreviewCard(
          font: font,
          labelText: resolveFontLabel(l, font.labelKey),
          hintText: resolveFontHint(l, font.hintKey),
          isSelected: font.id == selectedFamily,
          isLocked: isLocked,
          onTap: () => onPick(font.id),
        );
      },
    );
  }
}
