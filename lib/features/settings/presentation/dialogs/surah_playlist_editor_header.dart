import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';

/// Title row for [SurahPlaylistEditorDialog]. Renders the icon, title and
/// running count of currently-selected surahs (right-aligned).
class SurahPlaylistEditorHeader extends StatelessWidget {
  final AccentPalette palette;
  final int count;
  const SurahPlaylistEditorHeader({
    required this.palette,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Icon(Icons.playlist_play_rounded, color: palette.primary, size: 26),
        const SizedBox(width: 12),
        Text(
          l.surahPlaylistEditorTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          l.settingsQuranPlaylistCount(count),
          style: TextStyle(
            fontSize: 16,
            color: palette.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
