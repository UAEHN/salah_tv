import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../../core/app_colors.dart';
import 'prayer_panel_header.dart';
import 'prayer_row.dart';

class PrayerPanel extends StatelessWidget {
  const PrayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = context.select((PrayerBloc b) => b.state.todayPrayers);
    final nextPrayerKey = context.select(
      (PrayerBloc b) => b.state.nextPrayerKey,
    );
    final settings = context.watch<SettingsProvider>().settings;
    final isMultiCity = context.select((PrayerBloc b) => b.state.isMultiCity);
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Container(
      decoration: BoxDecoration(
        color: tc.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tc.borderGlass, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: settings.isDarkMode ? 0.4 : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            PrayerPanelHeader(
              palette: palette,
              selectedCity: settings.selectedCity,
              isMultiCity: isMultiCity,
            ),
            // Prayer rows
            Expanded(
              child: today == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: palette.primary.withValues(alpha: 0.6),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.noPrayerDataToday,
                            style: TextStyle(
                              fontSize: 18,
                              color: tc.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.checkCsvInSettings,
                            style: TextStyle(fontSize: 14, color: tc.textMuted),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: today.prayers.map((p) {
                        final delay = settings.iqamaDelays[p.key] ?? 10;
                        final offset = settings.adhanOffsets[p.key] ?? 0;
                        return Expanded(
                          child: PrayerRow(
                            prayer: p,
                            isNext: p.key == nextPrayerKey,
                            settings: settings,
                            iqamaDelay: delay,
                            adhanOffset: offset,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
