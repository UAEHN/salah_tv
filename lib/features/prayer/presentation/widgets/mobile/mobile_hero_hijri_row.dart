import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';

/// Date navigation row with glassmorphism pill and arrow buttons.
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
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: isBusy ? null : onPrevious,
          ),
          const SizedBox(width: 8),
          Expanded(child: _DatePill(
            hijriDate: hijriDate,
            gregorianDate: gregorianDate,
            isViewingToday: isViewingToday,
            isBusy: isBusy,
            backToTodayLabel: l.backToToday,
            onReset: onReset,
          )),
          const SizedBox(width: 8),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: isBusy ? null : onNext,
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;
  final bool isViewingToday;
  final bool isBusy;
  final String backToTodayLabel;
  final VoidCallback onReset;

  const _DatePill({
    required this.hijriDate,
    required this.gregorianDate,
    required this.isViewingToday,
    required this.isBusy,
    required this.backToTodayLabel,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isViewingToday ? null : onReset,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: MobileColors.cardColor(
                context,
              ).withValues(alpha: MobileColors.isDark(context) ? 0.4 : 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MobileColors.border(context).withValues(alpha: 0.5),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: MobileColors.primaryContainer,
                    size: 16,
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
                            color: MobileColors.onSurface(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          isViewingToday
                              ? gregorianDate
                              : '$gregorianDate - $backToTodayLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: MobileTextStyles.labelSm(context).copyWith(
                            color: MobileColors.onSurfaceMuted(context),
                            fontSize: 11,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  if (isBusy) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.cardColor(context).withValues(
                alpha: onTap == null
                    ? (isDark ? 0.2 : 0.4)
                    : (isDark ? 0.4 : 0.65),
              ),
              border: Border.all(
                color: MobileColors.border(context).withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              icon,
              color: MobileColors.onSurfaceMuted(context),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
