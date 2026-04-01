import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../settings_provider.dart';
import 'mobile_prayer_offset_row.dart';

const _prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

class MobilePrayerOffsetsList extends StatelessWidget {
  const MobilePrayerOffsetsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<SettingsProvider>();
    final settings = provider.settings;

    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildBackButton(context),
        const SizedBox(height: 8),
        _buildTitle(
          context,
          l.settingsAdjustAdhanTimeTitle,
          Icons.notifications_active_rounded,
        ),
        _buildSubtitle(context, l.settingsAdjustAdhanTimeSubtitle),
        const SizedBox(height: 12),
        ..._prayerKeys.map(
          (key) => _buildCard(
            context,
            label: localizedPrayerName(context, key),
            value: settings.adhanOffsets[key] ?? 0,
            unit: l.settingsMinuteShort,
            min: -30,
            max: 30,
            onChanged: (v) => provider.updateAdhanOffset(key, v),
          ),
        ),
        const SizedBox(height: 24),
        _buildTitle(context, l.settingsIqamaDelayTitle, Icons.timer_rounded),
        _buildSubtitle(context, l.settingsIqamaDelaySubtitle),
        const SizedBox(height: 12),
        ..._prayerKeys.map(
          (key) => _buildCard(
            context,
            label: localizedPrayerName(context, key),
            value: settings.iqamaDelays[key] ?? 0,
            unit: l.settingsMinuteShort,
            min: 0,
            max: 60,
            onChanged: (v) => provider.updateIqamaDelay(key, v),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: MobileColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              l.settingsAdjustTimes,
              style: MobileTextStyles.titleMd(context).copyWith(
                color: MobileColors.primary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18, color: MobileColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: MobileTextStyles.titleMd(context).copyWith(
              color: MobileColors.onSurface(context),
              fontSize: 16,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 12,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String label,
    required int value,
    required String unit,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MobileColors.cardColor(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MobileColors.border(context).withValues(alpha: 0.7),
        ),
      ),
      child: MobilePrayerOffsetRow(
        label: label,
        value: value,
        unit: unit,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}
