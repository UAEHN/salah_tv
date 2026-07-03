import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/adhan_sounds.dart';
import '../../../../../core/mobile_theme.dart';
import '../../bloc/adhan_preview_cubit.dart';
import '../../settings_provider.dart';
import 'mobile_adhan_sound_tile.dart';
import 'mobile_custom_adhan_section.dart';
import 'mobile_sound_dialog_save_button.dart';

/// Mobile bottom-sheet picker for the iqama notification sound. Mirrors
/// [MobileAdhanSoundDialog]: one bundled option (`iqama.mp3`, selection key
/// `'default'`) plus the user's imported iqama sounds. The default tile previews
/// via [kIqamaDefaultPreviewKey] so the iqama clip plays, not the adhan.
class MobileIqamaSoundDialog extends StatefulWidget {
  final String currentSound;
  final ValueChanged<String> onSave;

  const MobileIqamaSoundDialog({
    super.key,
    required this.currentSound,
    required this.onSave,
  });

  @override
  State<MobileIqamaSoundDialog> createState() => _MobileIqamaSoundDialogState();
}

class _MobileIqamaSoundDialogState extends State<MobileIqamaSoundDialog> {
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
              l.settingsChooseIqamaSound,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: MobileColors.onSurface(context), fontSize: 18),
            ),
            const SizedBox(height: 24),
            BlocBuilder<AdhanPreviewCubit, AdhanPreviewState>(
              builder: (context, previewState) => MobileAdhanSoundTile(
                label: l.settingsIqamaDefaultSound,
                isSelected: _selectedSound == 'default',
                isPlaying:
                    previewState is AdhanPreviewPlaying &&
                    previewState.soundKey == kIqamaDefaultPreviewKey,
                onSelect: () => setState(() => _selectedSound = 'default'),
                onPreview: () => context.read<AdhanPreviewCubit>().toggle(
                  kIqamaDefaultPreviewKey,
                ),
              ),
            ),
            MobileCustomAdhanSection(
              isIqama: true,
              adhans: context.watch<SettingsProvider>().settings.customIqamas,
              selectedKey: _selectedSound,
              onSelect: (key) => setState(() => _selectedSound = key),
            ),
            const SizedBox(height: 32),
            MobileSoundDialogSaveButton(
              label: l.commonSaveChanges,
              onSave: () {
                widget.onSave(_selectedSound);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
