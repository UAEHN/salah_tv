import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/surahs_data.dart';
import '../../../quran/domain/entities/quran_playback_mode.dart';
import '../dialogs/surah_picker_dialog.dart';
import '../settings_provider.dart';
import 'quran_count_picker.dart';
import '../../../../core/widgets/tv_button.dart';

/// Controls visible when [QuranPlaybackMode.singleSurah] is active:
/// surah picker + repeat-count picker + end-action toggle.
class QuranSingleSurahControls extends StatelessWidget {
  const QuranSingleSurahControls({super.key});

  static const _countOptions = [1, 3, 5, kInfiniteRepeat];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prov = context.watch<SettingsProvider>();
    final settings = prov.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    final selected = settings.selectedSurahNumber;
    final surah = selected == null ? null : surahByNumber(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: tc.glass(opacity: 0.06, borderRadius: 10),
                child: Text(
                  surah?.nameAr ?? l.settingsQuranNoSurahSelected,
                  style: TextStyle(
                    fontSize: 18,
                    color: surah != null ? tc.textPrimary : tc.textMuted,
                    fontWeight: surah != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TvButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SurahPickerDialog(
                  palette: palette,
                  selectedSurahNumber: selected,
                  onSelected: prov.updateSelectedSurah,
                ),
              ),
              accent: palette.primary,
              filled: true,
              child: Text(
                l.settingsQuranSelectSurah,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        QuranCountPicker(
          label: l.settingsQuranRepeatCount,
          currentCount: settings.surahRepeatCount,
          options: _countOptions,
          palette: palette,
          tc: tc,
          onChanged: prov.updateSurahRepeatCount,
        ),
      ],
    );
  }
}
