import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

class MobileTimeFormatDialog extends StatelessWidget {
  final bool is24Hour;
  final ValueChanged<bool> onSave;

  const MobileTimeFormatDialog({
    super.key,
    required this.is24Hour,
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
              l.settingsTimeFormat,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: MobileColors.onSurface(context), fontSize: 18),
            ),
            const SizedBox(height: 24),
            MobileSelectOptionTile(
              title: l.settings24HourEnabled,
              icon: Icons.schedule_rounded,
              isSelected: is24Hour,
              onTap: () {
                onSave(true);
                Navigator.pop(context);
              },
            ),
            MobileSelectOptionTile(
              title: l.settings12HourEnabled,
              icon: Icons.schedule_rounded,
              isSelected: !is24Hour,
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
