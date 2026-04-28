import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/surahs_data.dart';
import '../../../../core/widgets/tv_button.dart';

/// Sticky action panel for [SurahPlaylistEditorDialog]. Lives on the inline
/// (left) side of the dialog so the user can reach Save / Cancel /
/// Select-all / Clear with one D-Pad press from any list position.
class SurahPlaylistActionsPanel extends StatelessWidget {
  final AccentPalette palette;
  final Set<int> selected;
  final void Function(Set<int> next) onSelectionChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const SurahPlaylistActionsPanel({
    required this.palette,
    required this.selected,
    required this.onSelectionChanged,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelButton(
          icon: Icons.done_all_rounded,
          label: l.surahPlaylistEditorSelectAll,
          accent: palette.primary,
          onPressed: () =>
              onSelectionChanged({...kSurahs.map((s) => s.number)}),
        ),
        const SizedBox(height: 12),
        _PanelButton(
          icon: Icons.clear_all_rounded,
          label: l.surahPlaylistEditorClear,
          accent: palette.primary,
          onPressed: () => onSelectionChanged(<int>{}),
        ),
        const Spacer(),
        _PanelButton(
          icon: Icons.close_rounded,
          label: l.commonCancel,
          accent: palette.primary,
          onPressed: onCancel,
        ),
        const SizedBox(height: 12),
        _PanelButton(
          icon: Icons.check_circle_rounded,
          label: l.commonSave,
          accent: palette.primary,
          filled: true,
          onPressed: onSave,
        ),
      ],
    );
  }
}

class _PanelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool filled;
  final VoidCallback onPressed;

  const _PanelButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TvButton(
      onPressed: onPressed,
      accent: accent,
      filled: filled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
