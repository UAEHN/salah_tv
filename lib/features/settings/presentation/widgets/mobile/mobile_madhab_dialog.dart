import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

class MobileMadhabDialog extends StatelessWidget {
  final String currentMadhab;
  final ValueChanged<String> onSave;

  const MobileMadhabDialog({
    super.key,
    required this.currentMadhab,
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
            _buildHandle(context),
            const SizedBox(height: 20),
            _buildHeader(context, l),
            const SizedBox(height: 8),
            _buildNote(context, l),
            const SizedBox(height: 20),
            MobileSelectOptionTile(
              title: l.madhabShafiFamily,
              icon: Icons.mosque_rounded,
              isSelected: currentMadhab == 'shafi',
              onTap: () {
                onSave('shafi');
                Navigator.pop(context);
              },
            ),
            MobileSelectOptionTile(
              title: l.madhabHanafi,
              icon: Icons.mosque_rounded,
              isSelected: currentMadhab == 'hanafi',
              onTap: () {
                onSave('hanafi');
                Navigator.pop(context);
              },
            ),
            _buildAsrNote(context, l),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: MobileColors.onSurfaceMuted(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader(BuildContext context, AppLocalizations l) => Text(
        l.settingsMadhabLabel,
        style: MobileTextStyles.titleMd(context).copyWith(
          color: MobileColors.onSurface(context),
          fontSize: 18,
        ),
      );

  Widget _buildNote(BuildContext context, AppLocalizations l) => Text(
        l.settingsMadhabAffectsAsrNote,
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 12,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      );

  Widget _buildAsrNote(BuildContext context, AppLocalizations l) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: MobileColors.onSurfaceMuted(context),
            ),
            const SizedBox(width: 6),
            Text(
              l.settingsHanafiAsrLaterNote,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurfaceMuted(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}
