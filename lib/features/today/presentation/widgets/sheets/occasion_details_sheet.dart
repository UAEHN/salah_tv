import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/upcoming_occasion.dart';
import '../../logic/today_l10n_resolver.dart';

/// Bottom sheet shown on long-press of the occasion tile. Surfaces the
/// occasion's full label, days countdown, and Hijri month/day for context.
Future<void> showOccasionDetailsSheet(
  BuildContext context,
  UpcomingOccasion occasion,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _OccasionSheet(occasion: occasion),
  );
}

class _OccasionSheet extends StatelessWidget {
  final UpcomingOccasion occasion;

  const _OccasionSheet({required this.occasion});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final locale = Localizations.localeOf(context).languageCode;
    final label = resolveOccasionDisplayLabel(l, occasion, locale);
    final countdown = resolveDaysCountdown(l, occasion.daysUntil);

    return Container(
      decoration: BoxDecoration(
        color: MobileColors.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MobileColors.onSurfaceMuted(
                  context,
                ).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.nightlight_round, size: 30, color: accent),
            ),
            const SizedBox(height: 18),
            Text(
              label,
              style: MobileTextStyles.titleMd(context).copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                countdown,
                style: MobileTextStyles.labelSm(context).copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${occasion.hijriDay} / ${occasion.hijriMonth} ${l.hijriYearSuffix}',
              style: MobileTextStyles.labelSm(context).copyWith(
                color: MobileColors.onSurfaceMuted(context),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
