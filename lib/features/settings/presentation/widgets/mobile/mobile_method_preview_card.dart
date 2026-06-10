import 'package:flutter/material.dart';

import '../../../../../core/calculation_method_info.dart';
import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';
import '../../../../prayer/domain/entities/daily_prayer_times.dart';
import '../../logic/method_preview_computer.dart';

const _previewPrayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

/// Card that previews one calculation method by showing today's five
/// prayer times computed locally. Lets the user pick the method whose
/// schedule matches their local mosque before committing.
class MobileMethodPreviewCard extends StatelessWidget {
  final String methodKey;
  final double latitude;
  final double longitude;
  final String highLatitudeRuleKey;
  final bool isSuggested;
  final bool use24Hour;
  final VoidCallback onTap;

  const MobileMethodPreviewCard({
    required this.methodKey,
    required this.latitude,
    required this.longitude,
    required this.highLatitudeRuleKey,
    required this.onTap,
    required this.use24Hour,
    this.isSuggested = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final times = computePreviewForMethod(
      latitude: latitude,
      longitude: longitude,
      methodKey: methodKey,
      highLatitudeRuleKey: highLatitudeRuleKey,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSuggested
                    ? accent.withValues(alpha: 0.55)
                    : MobileColors.border(context),
                width: isSuggested ? 1.5 : 1,
              ),
              color: isSuggested
                  ? accent.withValues(alpha: 0.06)
                  : Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerRow(context, accent),
                const SizedBox(height: 10),
                if (times == null)
                  _emptyDash(context)
                else
                  _row(context, times),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerRow(BuildContext context, Color accent) {
    return Row(
      children: [
        if (isSuggested) ...[
          Icon(Icons.star_rounded, color: accent, size: 18),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            localizedCalculationMethod(context, methodKey),
            style: TextStyle(
              color: MobileColors.onSurface(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _emptyDash(BuildContext context) => Text(
    '—',
    style: TextStyle(color: MobileColors.onSurfaceMuted(context), fontSize: 12),
  );

  Widget _row(BuildContext context, DailyPrayerTimes times) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _previewPrayers
          .map(
            (k) => Expanded(
              child: Column(
                children: [
                  Text(
                    localizedPrayerName(context, k),
                    style: TextStyle(
                      color: MobileColors.onSurfaceMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPrayerTime(
                      previewTimeOf(times, k),
                      use24Hour: use24Hour,
                    ),
                    style: TextStyle(
                      color: MobileColors.onSurface(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
