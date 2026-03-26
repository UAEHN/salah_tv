import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/mobile_theme.dart';
import '../../settings_provider.dart';
import 'mobile_prayer_offset_row.dart';

const _prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
const _prayerLabels = {
  'fajr': 'الفجر',
  'dhuhr': 'الظهر',
  'asr': 'العصر',
  'maghrib': 'المغرب',
  'isha': 'العشاء',
};

class MobilePrayerOffsetsList extends StatelessWidget {
  const MobilePrayerOffsetsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final settings = provider.settings;

    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildBackButton(context),
        const SizedBox(height: 8),
        _buildTitle(context, 'ضبط وقت الأذان', Icons.notifications_active_rounded),
        _buildSubtitle(context, 'تقديم أو تأخير الأذان (−30 إلى +30 دقيقة)'),
        const SizedBox(height: 12),
        ..._prayerKeys.map(
          (key) => _buildCard(
            context,
            label: _prayerLabels[key]!,
            value: settings.adhanOffsets[key] ?? 0,
            unit: 'د',
            min: -30,
            max: 30,
            onChanged: (v) => provider.updateAdhanOffset(key, v),
          ),
        ),
        const SizedBox(height: 24),
        _buildTitle(context, 'تأخير الإقامة', Icons.timer_rounded),
        _buildSubtitle(context, 'عدد الدقائق بعد الأذان (0 إلى 60 دقيقة)'),
        const SizedBox(height: 12),
        ..._prayerKeys.map(
          (key) => _buildCard(
            context,
            label: _prayerLabels[key]!,
            value: settings.iqamaDelays[key] ?? 0,
            unit: 'د',
            min: 0,
            max: 60,
            onChanged: (v) => provider.updateIqamaDelay(key, v),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: MobileColors.primary),
              const SizedBox(width: 6),
              Text(
                'تعديل الأوقات',
                style: MobileTextStyles.titleMd(context).copyWith(
                  color: MobileColors.primary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTitle(BuildContext context, String text, IconData icon) => Padding(
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

  Widget _buildSubtitle(BuildContext context, String text) => Padding(
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

  Widget _buildCard(
    BuildContext context, {
    required String label,
    required int value,
    required String unit,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) =>
      Container(
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
