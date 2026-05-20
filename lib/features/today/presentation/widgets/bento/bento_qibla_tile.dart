import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../qibla/presentation/bloc/qibla_cubit.dart';
import '../../../../qibla/presentation/bloc/qibla_state.dart';
import 'bento_tile.dart';

/// Mini Qibla compass tile. Reads the live Qibla cubit through the widget
/// tree (the cubit is owned by `MobileShell` and provided to the qibla
/// tab — we surface the same instance via `BlocBuilder`).
///
/// Rendering:
///   • Northern label (eyebrow)
///   • Thin compass ring with a single accent arrow rotating to Mecca
///   • Distance in km below
class BentoQiblaTile extends StatelessWidget {
  const BentoQiblaTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final surface = BentoSurface.of(context);
    final accent = MobileColors.activePrimary(context);

    return BentoTile(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<QiblaCubit, QiblaState>(
        builder: (context, state) {
          final angle = state is QiblaActive
              ? (state.data.compassAngle * math.pi / 180)
              : 0.0;
          final distance = state is QiblaActive
              ? state.data.distanceKm.round()
              : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.todayQiblaTileLabel.toUpperCase(),
                style: MobileTextStyles.labelSm(context).copyWith(
                  fontSize: 10,
                  letterSpacing: 1.6,
                  color: surface.foregroundMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: surface.foregroundMuted.withValues(
                              alpha: 0.4,
                            ),
                            width: 1.4,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: angle,
                        child: Icon(
                          Icons.navigation_rounded,
                          size: 38,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (distance != null)
                Text(
                  '$distance ${l.todayQiblaKmUnit}',
                  style: MobileTextStyles.labelSm(context).copyWith(
                    fontSize: 11,
                    color: surface.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                ),
            ],
          );
        },
      ),
    );
  }
}
