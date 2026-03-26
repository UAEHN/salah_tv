import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileHeroHijriRow extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;
  final bool isViewingToday;
  final bool isBusy;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReset;

  const MobileHeroHijriRow({
    super.key,
    required this.hijriDate,
    required this.gregorianDate,
    required this.isViewingToday,
    required this.isBusy,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _arrowButton(context, Icons.chevron_left_rounded, onPrevious),
        const SizedBox(width: 10),
        Flexible(
          child: Center(
            child: GestureDetector(
              onTap: isViewingToday ? null : onReset,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: MobileColors.cardColor(
                    context,
                  ).withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: MobileColors.border(context).withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: MobileColors.onSurfaceMuted(context),
                      size: 14,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hijriDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: MobileTextStyles.bodyMd(context).copyWith(
                              color: MobileColors.onSurfaceMuted(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            isViewingToday
                                ? gregorianDate
                                : '$gregorianDate - العودة إلى اليوم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: MobileTextStyles.labelSm(context).copyWith(
                              color: MobileColors.onSurfaceMuted(context),
                              fontSize: 10,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    if (isBusy) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _arrowButton(context, Icons.chevron_right_rounded, onNext),
      ],
    );
  }

  Widget _arrowButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MobileColors.cardColor(
            context,
          ).withValues(alpha: isBusy ? 0.35 : 0.55),
        ),
        child: Icon(
          icon,
          color: MobileColors.onSurfaceMuted(context),
          size: 18,
        ),
      ),
    );
  }
}
