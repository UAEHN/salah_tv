import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/adhan_sounds.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/adhan_sound_localizer.dart';
import '../../../../core/widgets/tv_button.dart';
import '../../domain/entities/custom_adhan.dart';
import '../bloc/adhan_preview_cubit.dart';
import '../bloc/custom_adhan_cubit.dart';
import '../settings_provider.dart';
import '../widgets/tv/tv_sound_picker_tile.dart';
import 'tv_audio_browser_dialog.dart';

/// Unified TV sound picker for adhan ([isIqama] false) and iqama
/// ([isIqama] true): built-in sounds + user-imported list (with delete) + an
/// "import from device" action that opens the D-pad file browser. Selection
/// and the custom list are read live from [SettingsProvider]. The hosting
/// widget must provide a [CustomAdhanCubit] above this dialog.
class TvSoundPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final bool isIqama;

  const TvSoundPickerDialog({
    required this.palette,
    required this.isIqama,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final customs = isIqama ? settings.customIqamas : settings.customAdhans;
    final selectedKey = isIqama ? settings.iqamaSound : settings.adhanSound;
    final onSelect = isIqama
        ? settingsProv.updateIqamaSound
        : settingsProv.updateAdhanSound;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 520,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title(context, l),
                const Divider(color: Colors.white12),
                Flexible(
                  child: BlocBuilder<AdhanPreviewCubit, AdhanPreviewState>(
                    builder: (ctx, preview) => ListView(
                      shrinkWrap: true,
                      children: [
                        ..._builtInTiles(ctx, selectedKey, onSelect, preview),
                        ..._customTiles(
                          ctx,
                          customs,
                          selectedKey,
                          onSelect,
                          preview,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _addButton(context, l),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context, AppLocalizations l) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(Icons.volume_up_rounded, color: palette.primary, size: 26),
        const SizedBox(width: 12),
        Text(
          isIqama ? l.settingsChooseIqamaSound : l.settingsChooseAdhanSound,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  List<Widget> _builtInTiles(
    BuildContext context,
    String selectedKey,
    ValueChanged<String> onSelect,
    AdhanPreviewState preview,
  ) {
    final l = AppLocalizations.of(context);
    final entries = isIqama
        ? [(key: 'default', label: l.iqamaDefaultSound)]
        : kAdhanSounds
              .map(
                (s) => (
                  key: s.key,
                  label: localizedAdhanSoundLabel(context, s.key),
                ),
              )
              .toList();
    return [
      for (var i = 0; i < entries.length; i++)
        TvSoundPickerTile(
          label: entries[i].label,
          isSelected: entries[i].key == selectedKey,
          palette: palette,
          autofocus: i == 0,
          isPreviewing: _isPreviewing(preview, entries[i].key),
          onSelect: () => onSelect(entries[i].key),
          onPreview: () => _togglePreview(context, entries[i].key),
        ),
    ];
  }

  List<Widget> _customTiles(
    BuildContext context,
    List<CustomAdhan> customs,
    String selectedKey,
    ValueChanged<String> onSelect,
    AdhanPreviewState preview,
  ) {
    final l = AppLocalizations.of(context);
    return [
      for (final c in customs)
        TvSoundPickerTile(
          label: c.label,
          isSelected: c.settingsKey == selectedKey,
          palette: palette,
          isPreviewing: _isPreviewing(preview, c.settingsKey),
          onSelect: () => onSelect(c.settingsKey),
          onPreview: () => _togglePreview(context, c.settingsKey),
          onDelete: () => _confirmDelete(context, l, c),
        ),
    ];
  }

  /// The iqama selection key `'default'` maps to the default *adhan* asset in
  /// the shared resolver, so preview uses a distinct key for the iqama clip.
  String _previewKey(String selectionKey) =>
      (isIqama && selectionKey == 'default')
      ? kIqamaDefaultPreviewKey
      : selectionKey;

  bool _isPreviewing(AdhanPreviewState preview, String selectionKey) =>
      preview is AdhanPreviewPlaying &&
      preview.soundKey == _previewKey(selectionKey);

  void _togglePreview(BuildContext context, String selectionKey) =>
      context.read<AdhanPreviewCubit>().toggle(_previewKey(selectionKey));

  Widget _addButton(BuildContext context, AppLocalizations l) {
    return BlocConsumer<CustomAdhanCubit, CustomAdhanState>(
      listener: (ctx, state) {
        if (state is CustomAdhanError) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          ctx.read<CustomAdhanCubit>().clearError();
        }
      },
      builder: (ctx, state) {
        final busy = state is CustomAdhanBusy;
        return TvButton(
          onPressed: busy ? () {} : () => _addFromDevice(ctx),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                l.settingsAddCustomAdhan,
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addFromDevice(BuildContext context) async {
    final cubit = context.read<CustomAdhanCubit>();
    final path = await showTvAudioBrowser(context, palette);
    if (path == null) return;
    await cubit.importFromDevicePath(path, isIqama: isIqama);
  }

  void _confirmDelete(BuildContext context, AppLocalizations l, CustomAdhan c) {
    final cubit = context.read<CustomAdhanCubit>();
    showDialog<void>(
      context: context,
      builder: (dCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF0A1628),
          title: Text(
            l.settingsDeleteAdhan,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(c.label, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: Text(l.commonCancel),
            ),
            TextButton(
              onPressed: () {
                cubit.removeSound(c.id, isIqama: isIqama);
                Navigator.pop(dCtx);
              },
              child: Text(l.commonDelete),
            ),
          ],
        ),
      ),
    );
  }
}
