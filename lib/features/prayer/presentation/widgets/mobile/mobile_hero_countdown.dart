import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';
import '../mobile_countdown_arc_painter.dart';

class MobileHeroCountdown extends StatelessWidget {
  final String nextPrayerKey;
  final Duration countdown;
  final bool isCycleActive;
  final bool isIqamaCountdown;
  final Duration iqamaCountdown;
  final String iqamaPrayerKey;
  final double progress;
  final double iqamaProgress;

  const MobileHeroCountdown({
    super.key,
    required this.nextPrayerKey,
    required this.countdown,
    required this.isCycleActive,
    required this.isIqamaCountdown,
    required this.iqamaCountdown,
    required this.iqamaPrayerKey,
    required this.progress,
    required this.iqamaProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nextPrayerName = localizedPrayerName(context, nextPrayerKey);
    final iqamaPrayerName = localizedPrayerName(context, iqamaPrayerKey);

    final size =
        (MediaQuery.of(context).size.height * 0.33).clamp(160.0, 256.0);
    final innerSize = size - 20;

    return SizedBox(
      width: size,
      height: size,
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
            width: innerSize,
            height: innerSize,
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
            size: Size(size, size),
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
                              : MobileColors.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
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
                    ? l.countdownToIqama(iqamaPrayerName)
                    : isCycleActive
                    ? l.ongoingNow
                    : l.countdownNextPrayer(nextPrayerName),
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
