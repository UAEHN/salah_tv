import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/upcoming_occasion.dart';
import '../../logic/today_l10n_resolver.dart';
import '../sheets/occasion_details_sheet.dart';
import 'bento_tile.dart';

/// Compact square tile reserved for the next Hijri occasion.
/// Big number on top (countdown), small label below it.
class BentoOccasionTile extends StatelessWidget {
  final UpcomingOccasion occasion;

  const BentoOccasionTile({super.key, required this.occasion});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final surface = BentoSurface.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final label = resolveOccasionDisplayLabel(l, occasion, locale);

    return GestureDetector(
      onLongPress: () => showOccasionDetailsSheet(context, occasion),
      child: BentoTile(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (occasion.daysUntil == 0)
              Text(
                l.todayOccasionToday,
                style: MobileTextStyles.titleMd(context).copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
              )
            else ...[
              Text(
                '${occasion.daysUntil}',
                style: TextStyle(
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.fontFamily,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  height: 1.0,
                  letterSpacing: -1.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                occasion.daysUntil == 1
                    ? l.todayOccasionTomorrow
                    : l.todayDaysUnit,
                style: MobileTextStyles.labelSm(context).copyWith(
                  fontSize: 12,
                  color: surface.foregroundMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                style: MobileTextStyles.bodyMd(context).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: surface.foreground,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
