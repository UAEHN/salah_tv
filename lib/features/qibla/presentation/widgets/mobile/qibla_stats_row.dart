import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

/// Two side-by-side stat cards under the compass. Monochrome with a single
/// theme accent — no more competing orange/peach numbers.
class QiblaStatsRow extends StatelessWidget {
  final String distance;
  final String deviation;

  const QiblaStatsRow({
    super.key,
    required this.distance,
    required this.deviation,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.straighten_rounded,
            title: l.qiblaDistanceToKaaba,
            value: distance,
            unit: l.unitKm,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.explore_rounded,
            title: l.qiblaDeviation,
            value: deviation,
            unit: l.unitDegree,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    final accent = MobileColors.activePrimary(context);
    final onSurface = MobileColors.onSurface(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MobileColors.border(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: accent.withValues(alpha: 0.9), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: MobileColors.onSurfaceMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                  height: 1.0,
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: MobileColors.onSurfaceMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
