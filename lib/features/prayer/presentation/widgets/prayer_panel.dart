import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_list_item_mapper.dart';
import 'classic/classic_visuals.dart';
import 'prayer_row.dart';

/// Classic prayer list — a rounded panel of equal-height rows separated by
/// faint hairlines (design `.panel`). No header: the rows fill the card.
class PrayerPanel extends StatelessWidget {
  const PrayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final today = context.select((PrayerBloc b) => b.state.todayPrayers);
    final nextPrayerKey = context.select(
      (PrayerBloc b) => b.state.nextPrayerKey,
    );
    final settings = context.watch<SettingsProvider>().settings;
    final vis = ClassicVisuals(
      ThemeColors.of(settings.isDarkMode),
      getThemePalette(settings.themeColorKey),
    );
    final items = today == null
        ? const <PrayerPanelItem>[]
        : mapPrayerPanelItems(
            today: today,
            nextPrayerKey: nextPrayerKey,
            settings: settings,
          );

    return Container(
      decoration: BoxDecoration(
        color: vis.panelBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: vis.line, width: 1),
        boxShadow: vis.panelShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        // Prayer rows are Arabic: force RTL so the name leads on the right and
        // the time cell sits on the left (TV is globally LTR).
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: today == null
              ? _EmptyState(vis: vis)
              : Column(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: i == 0
                                ? null
                                : Border(top: BorderSide(color: vis.line)),
                          ),
                          child: PrayerRow(
                            prayer: items[i].prayer,
                            isNext: items[i].isNext,
                            settings: settings,
                            iqamaDelay: items[i].iqamaDelay,
                            adhanOffset: items[i].adhanOffset,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ClassicVisuals vis;

  const _EmptyState({required this.vis});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: vis.fgSec.withValues(alpha: 0.6),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l.noPrayerDataToday,
            style: TextStyle(fontSize: 18, color: vis.fgSec),
          ),
          const SizedBox(height: 8),
          Text(
            l.checkCsvInSettings,
            style: TextStyle(fontSize: 14, color: vis.fgMuted),
          ),
        ],
      ),
    );
  }
}
