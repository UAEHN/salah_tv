import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/qibla_accuracy.dart';
import '../../../domain/entities/qibla_data.dart';
import 'qibla_accuracy_badge.dart';
import 'qibla_calibration_guide.dart';
import 'qibla_compass.dart';
import 'qibla_stats_row.dart';

/// Active Qibla view shown when GPS + sensors are working. Cleaner stack:
/// title, inline accuracy hint, compass, optional calibration guide, stats.
class MobileQiblaActiveView extends StatelessWidget {
  final QiblaData data;

  const MobileQiblaActiveView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAligned = data.isAligned;
    final accent = MobileColors.activePrimary(context);

    return Column(
      children: [
        const SizedBox(height: 14),
        Text(
          isAligned ? l.qiblaAlignedStatus : l.qiblaFindStatus,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: isAligned ? accent : MobileColors.onSurface(context),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        QiblaAccuracyBadge(accuracy: data.accuracy),
        const SizedBox(height: 28),
        Expanded(
          child: Center(
            child: QiblaCompass(
              qiblaBearing: data.qiblaBearing,
              deviceHeading: data.deviceHeading,
              isAligned: isAligned,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (data.accuracy == QiblaAccuracy.low) ...[
          const QiblaCalibrationGuide(),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: QiblaStatsRow(
            distance: data.distanceKm.toStringAsFixed(0),
            deviation: data.deviation.abs().toStringAsFixed(1),
          ),
        ),
        const SizedBox(height: 110),
      ],
    );
  }
}
