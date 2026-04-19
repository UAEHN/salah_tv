import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/qibla_accuracy.dart';
import '../../../domain/entities/qibla_data.dart';
import 'qibla_accuracy_badge.dart';
import 'qibla_calibration_guide.dart';
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

    return Column(
      children: [
        Text(
          isAligned ? l.qiblaAlignedStatus : l.qiblaFindStatus,
          style: MobileTextStyles.titleMd(context).copyWith(
            color: isAligned
                ? MobileColors.primaryContainer
                : MobileColors.onSurface(context),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isAligned ? l.qiblaAlignedSub : l.qiblaFindSub,
          style: MobileTextStyles.labelSm(context).copyWith(
            color: MobileColors.onSurfaceMuted(context),
            letterSpacing: 4.0,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        QiblaAccuracyBadge(accuracy: data.accuracy),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: QiblaCompass(
              qiblaBearing: data.qiblaBearing,
              deviceHeading: data.deviceHeading,
              isAligned: isAligned,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (data.accuracy == QiblaAccuracy.low) ...[
          const QiblaCalibrationGuide(),
          const SizedBox(height: 12),
        ],
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
