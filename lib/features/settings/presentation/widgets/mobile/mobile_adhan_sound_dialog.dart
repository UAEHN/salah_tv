import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/adhan_sounds.dart';
import '../../../../../core/localization/adhan_sound_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

class MobileAdhanSoundDialog extends StatefulWidget {
  final String currentSound;
  final ValueChanged<String> onSave;

  const MobileAdhanSoundDialog({
    super.key,
    required this.currentSound,
    required this.onSave,
  });

  @override
  State<MobileAdhanSoundDialog> createState() => _MobileAdhanSoundDialogState();
}

class _MobileAdhanSoundDialogState extends State<MobileAdhanSoundDialog> {
  late String _selectedSound;

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.currentSound;
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
              l.settingsChooseAdhanSound,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: MobileColors.onSurface(context), fontSize: 18),
            ),
            const SizedBox(height: 24),
            ...kAdhanSounds.map(
              (sound) => MobileSelectOptionTile(
                title: localizedAdhanSoundLabel(context, sound.key),
                icon: Icons.graphic_eq_rounded,
                isSelected: _selectedSound == sound.key,
                onTap: () => setState(() => _selectedSound = sound.key),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_selectedSound);
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
                      l.commonSaveChanges,
                      style: MobileTextStyles.titleMd(
                        context,
                      ).copyWith(color: Colors.white, fontSize: 16),
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
