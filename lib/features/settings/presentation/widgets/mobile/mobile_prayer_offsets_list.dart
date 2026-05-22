import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../settings_provider.dart';
import 'mobile_prayer_offset_row.dart';
import 'mobile_prayer_offset_section.dart';

const _prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

class MobilePrayerOffsetsList extends StatelessWidget {
  const MobilePrayerOffsetsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<SettingsProvider>();
    final settings = provider.settings;

    return Column(
      children: [
        _Header(title: l.settingsAdjustTimes),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 8,
              bottom: 120,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              MobilePrayerOffsetSection(
                title: l.settingsAdjustAdhanTimeTitle,
                subtitle: l.settingsAdjustAdhanTimeSubtitle,
                icon: Icons.notifications_active_rounded,
                rows: [
                  for (final key in _prayerKeys)
                    MobilePrayerOffsetRow(
                      label: localizedPrayerName(context, key),
                      value: settings.adhanOffsets[key] ?? 0,
                      unit: l.settingsMinuteShort,
                      min: -30,
                      max: 30,
                      onChanged: (v) => provider.updateAdhanOffset(key, v),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              MobilePrayerOffsetSection(
                title: l.settingsIqamaDelayTitle,
                subtitle: l.settingsIqamaDelaySubtitle,
                icon: Icons.timer_rounded,
                rows: [
                  for (final key in _prayerKeys)
                    MobilePrayerOffsetRow(
                      label: localizedPrayerName(context, key),
                      value: settings.iqamaDelays[key] ?? 0,
                      unit: l.settingsMinuteShort,
                      min: 0,
                      max: 60,
                      onChanged: (v) => provider.updateIqamaDelay(key, v),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            title,
            style: MobileTextStyles.titleMd(context).copyWith(
              color: MobileColors.onSurface(context),
              fontSize: 22,
            ),
            textDirection: TextDirection.rtl,
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: MobileColors.onSurface(context),
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ],
      ),
    );
  }
}
