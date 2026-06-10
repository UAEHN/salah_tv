import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/adhan_sounds.dart';
import '../../../../../core/localization/adhan_sound_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../bloc/adhan_preview_cubit.dart';
import '../../settings_provider.dart';
import 'mobile_adhan_sound_tile.dart';
import 'mobile_custom_adhan_section.dart';

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
            BlocBuilder<AdhanPreviewCubit, AdhanPreviewState>(
              builder: (context, previewState) => Column(
                children: kAdhanSounds
                    .map(
                      (sound) => MobileAdhanSoundTile(
                        label: localizedAdhanSoundLabel(context, sound.key),
                        isSelected: _selectedSound == sound.key,
                        isPlaying:
                            previewState is AdhanPreviewPlaying &&
                            previewState.soundKey == sound.key,
                        onSelect: () =>
                            setState(() => _selectedSound = sound.key),
                        onPreview: () =>
                            context.read<AdhanPreviewCubit>().toggle(sound.key),
                      ),
                    )
                    .toList(),
              ),
            ),
            MobileCustomAdhanSection(
              adhans: context.watch<SettingsProvider>().settings.customAdhans,
              selectedKey: _selectedSound,
              onSelect: (key) => setState(() => _selectedSound = key),
            ),
            const SizedBox(height: 32),
            _SaveButton(
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

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final String label;

  const _SaveButton({required this.onSave, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSave,
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
              colors: [MobileColors.primary, MobileColors.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              label,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
