import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';

/// «─── فهرس السور ───» divider rendered between the landing CTA block
/// and the surah index. Extracted to keep the screen file under
/// 150 lines per CLAUDE.md §4.
class MobileMushafIndexDivider extends StatelessWidget {
  const MobileMushafIndexDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final faint = MobileColors.onSurfaceFaint(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: faint, thickness: 0.6, endIndent: 12),
          ),
          Text(
            AppLocalizations.of(context).mushafSurahIndex,
            style: MobileTextStyles.headlineMd(context),
          ),
          Expanded(
            child: Divider(color: faint, thickness: 0.6, indent: 12),
          ),
        ],
      ),
    );
  }
}
