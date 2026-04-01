import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/qibla_data.dart';
import 'qibla_compass.dart';
import 'qibla_stats_row.dart';

/// Active Qibla view shown when GPS + sensors are working.
class MobileQiblaActiveView extends StatelessWidget {
  final QiblaData data;

  const MobileQiblaActiveView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAligned = data.isAligned;
    final statusText = isAligned ? l.qiblaAlignedStatus : l.qiblaFindStatus;
    final statusSub = isAligned ? l.qiblaAlignedSub : l.qiblaFindSub;

    return Column(
      children: [
        Text(
          statusText,
          style: MobileTextStyles.titleMd(context).copyWith(
            color: isAligned
                ? MobileColors.primaryContainer
                : MobileColors.onSurface(context),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusSub,
          style: MobileTextStyles.labelSm(context).copyWith(
            color: MobileColors.onSurfaceMuted(context),
            letterSpacing: 4.0,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 48),
        Expanded(
          child: Center(
            child: QiblaCompass(
              qiblaBearing: data.qiblaBearing,
              deviceHeading: data.deviceHeading,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: QiblaStatsRow(
            distance: data.distanceKm.toStringAsFixed(0),
            deviation: data.deviation.abs().toStringAsFixed(1),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}
