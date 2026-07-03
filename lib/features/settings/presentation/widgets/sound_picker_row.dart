import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/widgets/tv_button.dart';
import '../../../../injection.dart';
import '../bloc/adhan_preview_cubit.dart';
import '../bloc/custom_adhan_cubit.dart';
import '../dialogs/tv_sound_picker_dialog.dart';

/// Shared "current sound + change button" row used by both the adhan and the
/// iqama sound settings (DRY — CLAUDE.md §4). Opens the unified
/// [TvSoundPickerDialog] for the matching category, re-providing the ambient
/// [CustomAdhanCubit] across the dialog route boundary.
class SoundPickerRow extends StatelessWidget {
  final AccentPalette palette;
  final ThemeColors tc;
  final String currentLabel;
  final String changeLabel;
  final bool isIqama;

  const SoundPickerRow({
    required this.palette,
    required this.tc,
    required this.currentLabel,
    required this.changeLabel,
    required this.isIqama,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: tc.glass(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.volume_up_rounded, color: palette.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentLabel,
                    style: TextStyle(
                      fontSize: 18,
                      color: tc.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        TvButton(
          onPressed: () => _open(context),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                changeLabel,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context) {
    final cubit = context.read<CustomAdhanCubit>();
    showDialog<void>(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          // Fresh per-dialog instance: its close() stops playback when the
          // picker is dismissed, so preview never leaks past the dialog.
          BlocProvider(create: (_) => getIt<AdhanPreviewCubit>()),
        ],
        child: TvSoundPickerDialog(palette: palette, isIqama: isIqama),
      ),
    );
  }
}

/// Resolves the display label of a selected sound key: the user's custom label
/// when it is a `custom:` key, otherwise [builtInLabel].
String soundDisplayLabel(
  String selectedKey,
  Iterable<({String key, String label})> customLabels,
  String builtInLabel,
) {
  for (final c in customLabels) {
    if (c.key == selectedKey) return c.label;
  }
  return builtInLabel;
}
