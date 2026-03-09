import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import '../dialogs/reciter_picker_dialog.dart';
import 'tv_button.dart';
import 'tv_switch_row.dart';

class QuranSection extends StatelessWidget {
  const QuranSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TvSwitchRow(
          value: settings.isQuranEnabled,
          accent: palette.primary,
          onChanged: (v) => settingsProv.updateIsQuranEnabled(v),
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: settings.isQuranEnabled ? palette.primary : tc.textMuted,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              'تشغيل القرآن في الخلفية:',
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.isQuranEnabled,
              activeTrackColor: palette.primary,
              inactiveTrackColor: tc.textMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: (v) => settingsProv.updateIsQuranEnabled(v),
            ),
            const SizedBox(width: 12),
            Text(
              settings.isQuranEnabled ? 'مفعّل' : 'معطّل',
              style: TextStyle(
                fontSize: 20,
                color: settings.isQuranEnabled ? palette.primary : tc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (settings.isQuranEnabled) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: tc.glass(opacity: 0.06, borderRadius: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: settings.hasQuranReciter ? palette.primary : tc.textMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings.hasQuranReciter
                              ? settings.quranReciterName
                              : 'لم يتم اختيار قاريء',
                          style: TextStyle(
                            fontSize: 18,
                            color: settings.hasQuranReciter ? tc.textPrimary : tc.textMuted,
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
                  builder: (_) => ReciterPickerDialog(
                    palette: palette,
                    currentServerUrl: settings.quranReciterServerUrl,
                    onSelected: (name, serverUrl) =>
                        settingsProv.updateQuranReciter(name, serverUrl),
                  ),
                ),
                accent: palette.primary,
                filled: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_search_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تغيير القاريء',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: tc.glass(opacity: 0.05, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.wifi_rounded, color: tc.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يتطلب اتصالاً بالإنترنت لتحميل قائمة القراء وتشغيل القرآن.',
                    style: TextStyle(fontSize: 14, color: tc.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
