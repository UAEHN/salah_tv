import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

class MobilePreAdhanDurationDialog extends StatefulWidget {
  final int currentMinutes;
  final ValueChanged<int> onSave;
  final String title;

  const MobilePreAdhanDurationDialog({
    super.key,
    required this.currentMinutes,
    required this.onSave,
    required this.title,
  });

  @override
  State<MobilePreAdhanDurationDialog> createState() =>
      _MobilePreAdhanDurationDialogState();
}

class _MobilePreAdhanDurationDialogState
    extends State<MobilePreAdhanDurationDialog> {
  late int _selected;

  static const _options = [5, 10, 15, 30];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentMinutes;
  }

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
              widget.title,
              style: MobileTextStyles.titleMd(context).copyWith(
                color: MobileColors.onSurface(context),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ..._options.map(
              (min) => MobileSelectOptionTile(
                title: l.settingsDurationMinutes(min),
                icon: Icons.timer_outlined,
                isSelected: _selected == min,
                onTap: () => setState(() => _selected = min),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_selected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ).copyWith(elevation: WidgetStateProperty.all(0)),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        MobileColors.primary,
                        MobileColors.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l.commonSave,
                      style: MobileTextStyles.titleMd(context).copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
