import 'package:flutter/material.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/calculation_method_info.dart';
import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/time_formatters.dart';
import '../../../../prayer/domain/entities/daily_prayer_times.dart';
import '../../logic/method_preview_computer.dart';

const _previewPrayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

/// Inner layout of a TV method preview tile: title row + five-prayer
/// preview line (or em-dash if calculation failed). Split out of the
/// focusable wrapper purely to keep both files under the 150-line cap.
class TvMethodPreviewBody extends StatelessWidget {
  final String methodKey;
  final DailyPrayerTimes? times;
  final bool isSuggested;
  final bool use24Hour;
  final ThemeColors tc;
  final Color accent;

  const TvMethodPreviewBody({
    required this.methodKey,
    required this.times,
    required this.isSuggested,
    required this.use24Hour,
    required this.tc,
    required this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (isSuggested) ...[
              Icon(Icons.star_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                localizedCalculationMethod(context, methodKey),
                style: TextStyle(
                  color: tc.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (times == null)
          Text('—', style: TextStyle(color: tc.textMuted, fontSize: 14))
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _previewPrayers
                .map(
                  (k) => Expanded(
                    child: Column(
                      children: [
                        Text(
                          localizedPrayerName(context, k),
                          style: TextStyle(
                            color: tc.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatPrayerTime(
                            previewTimeOf(times!, k),
                            use24Hour: use24Hour,
                          ),
                          style: TextStyle(
                            color: tc.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}
