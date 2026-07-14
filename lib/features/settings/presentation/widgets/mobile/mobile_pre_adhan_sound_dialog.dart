import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../settings_provider.dart';
import 'mobile_adhan_sound_tile.dart';
import 'mobile_custom_adhan_section.dart';
import 'mobile_sound_dialog_save_button.dart';

/// Bottom-sheet picker for a per-prayer pre-adhan reminder sound. Unlike the
/// adhan picker, the only non-custom option is «صامت» (a soundless heads-up);
/// custom sounds are shared with the adhan list and imported via the same flow.
class MobilePreAdhanSoundDialog extends StatefulWidget {
  final String currentSound;
  final ValueChanged<String> onSave;

  const MobilePreAdhanSoundDialog({
    super.key,
    required this.currentSound,
    required this.onSave,
  });

  @override
  State<MobilePreAdhanSoundDialog> createState() =>
      _MobilePreAdhanSoundDialogState();
}

class _MobilePreAdhanSoundDialogState extends State<MobilePreAdhanSoundDialog> {
  static const _silent = 'silent';
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
              l.settingsChoosePreAdhanSound,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: MobileColors.onSurface(context), fontSize: 18),
            ),
            const SizedBox(height: 24),
            // «صامت» — the soundless default; no preview (nothing to play).
            MobileAdhanSoundTile(
              label: l.settingsPreAdhanSoundSilent,
              isSelected: _selectedSound == _silent,
              isPlaying: false,
              onSelect: () => setState(() => _selectedSound = _silent),
            ),
            MobileCustomAdhanSection(
              adhans: context.watch<SettingsProvider>().settings.customAdhans,
              selectedKey: _selectedSound,
              onSelect: (key) => setState(() => _selectedSound = key),
            ),
            const SizedBox(height: 32),
            MobileSoundDialogSaveButton(
              onSave: () {
                widget.onSave(_selectedSound);
                Navigator.pop(context);
              },
              label: l.commonSaveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
