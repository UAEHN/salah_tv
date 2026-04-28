import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../quran/domain/entities/quran_playback_mode.dart';
import '../dialogs/surah_playlist_editor_dialog.dart';
import '../settings_provider.dart';
import 'quran_count_picker.dart';
import '../../../../core/widgets/tv_button.dart';

/// Controls visible when [QuranPlaybackMode.playlist] is active:
/// playlist editor + cycle-count picker.
class QuranPlaylistControls extends StatelessWidget {
  const QuranPlaylistControls({super.key});

  static const _cycleOptions = [1, 3, kInfiniteRepeat];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prov = context.watch<SettingsProvider>();
    final settings = prov.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final playlist = settings.surahPlaylist;
    final label = playlist.isEmpty
        ? l.settingsQuranPlaylistEmpty
        : l.settingsQuranPlaylistCount(playlist.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: tc.glass(opacity: 0.06, borderRadius: 10),
                child: Text(label,
                    style: TextStyle(
                      fontSize: 18,
                      color: playlist.isEmpty ? tc.textMuted : tc.textPrimary,
                      fontWeight: playlist.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w600,
                    )),
              ),
            ),
            const SizedBox(width: 16),
            TvButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SurahPlaylistEditorDialog(
                  palette: palette,
                  initialSelection: playlist,
                  onSaved: prov.updateSurahPlaylist,
                ),
              ),
              accent: palette.primary,
              filled: true,
              child: Text(l.settingsQuranEditPlaylist,
                  style:
                      const TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        QuranCountPicker(
          label: l.settingsQuranCycleCount,
          currentCount: settings.playlistCycleCount,
          options: _cycleOptions,
          palette: palette,
          tc: tc,
          onChanged: prov.updatePlaylistCycleCount,
        ),
      ],
    );
  }
}
