import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../dialogs/reciter_picker_dialog.dart';
import '../settings_provider.dart';
import '../../../../core/widgets/tv_button.dart';

/// Reciter display + change-reciter button. Shows the current reciter name
/// (or a placeholder when none is selected) alongside the picker entry-point.
class QuranReciterRow extends StatelessWidget {
  const QuranReciterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: tc.glass(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: settings.hasQuranReciter
                      ? palette.primary
                      : tc.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    settings.hasQuranReciter
                        ? settings.quranReciterName
                        : l.settingsNoReciterSelected,
                    style: TextStyle(
                      fontSize: 18,
                      color: settings.hasQuranReciter
                          ? tc.textPrimary
                          : tc.textMuted,
                      fontWeight: settings.hasQuranReciter
                          ? FontWeight.w600
                          : FontWeight.normal,
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
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProv,
              child: ReciterPickerDialog(
                palette: palette,
                currentServerUrl: settings.quranReciterServerUrl,
                language: l.localeName,
                onSelected: (name, serverUrl) =>
                    settingsProv.updateQuranReciter(name, serverUrl),
              ),
            ),
          ),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_search_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l.settingsChangeReciter,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
