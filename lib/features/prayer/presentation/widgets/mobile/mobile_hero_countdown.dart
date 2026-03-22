import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';
import '../mobile_countdown_arc_painter.dart';

class MobileHeroCountdown extends StatelessWidget {
  final String nextPrayerName;
  final Duration countdown;
  final bool isCycleActive;
  final bool isIqamaCountdown;
  final Duration iqamaCountdown;
  final String iqamaPrayerName;
  final double progress;
  final double iqamaProgress;

  const MobileHeroCountdown({
    super.key,
    required this.nextPrayerName,
    required this.countdown,
    required this.isCycleActive,
    required this.isIqamaCountdown,
    required this.iqamaCountdown,
    required this.iqamaPrayerName,
    required this.progress,
    required this.iqamaProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: MobileColors.cardColor(context),
                width: 6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
          ),
          Container(
            width: 236,
            height: 236,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isIqamaCountdown
                      ? MobileColors.iqamaAccent.withValues(alpha: 0.12)
                      : MobileColors.primaryContainer.withValues(alpha: 0.12),
                  blurRadius: 36,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(256, 256),
            painter: MobileCountdownArcPainter(
              progress: isIqamaCountdown ? iqamaProgress : progress,
              arcColor: isIqamaCountdown
                  ? MobileColors.iqamaAccent
                  : MobileColors.primaryContainer,
              trackColor: MobileColors.onSurfaceFaint(
                context,
              ).withValues(alpha: 0.18),
              strokeWidth: 12,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isIqamaCountdown
                        ? formatCountdown(iqamaCountdown)
                        : isCycleActive
                            ? iqamaPrayerName
                            : formatCountdown(countdown),
                    maxLines: 1,
                    style: MobileTextStyles.displayLg(context).copyWith(
                      fontSize: isCycleActive && !isIqamaCountdown ? 36 : 64,
                      fontFeatures: isCycleActive && !isIqamaCountdown
                          ? null
                          : const [FontFeature.tabularFigures()],
                      shadows: [
                        BoxShadow(
                          color: isIqamaCountdown
                              ? MobileColors.iqamaAccent.withValues(alpha: 0.5)
                              : MobileColors.primaryContainer.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isIqamaCountdown
                    ? 'باقي على إقامة $iqamaPrayerName'
                    : isCycleActive
                        ? 'جارٍ الآن'
                        : 'باقي على صلاة $nextPrayerName',
                style: MobileTextStyles.bodyMd(context).copyWith(
                  color: MobileColors.onSurfaceMuted(context),
                  fontSize: 12,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
