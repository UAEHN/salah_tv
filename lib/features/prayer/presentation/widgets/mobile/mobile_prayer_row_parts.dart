import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_prayer_visuals.dart';

class MobilePrayerIcon extends StatelessWidget {
  final String prayerKey;
  final bool isActive;
  final bool isDark;
  final double containerSize;
  final double contentSize;

  const MobilePrayerIcon({
    super.key,
    required this.prayerKey,
    required this.isActive,
    required this.isDark,
    required this.containerSize,
    required this.contentSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = mobilePrayerAccentPair(context, prayerKey);
    final accentColor = colors.$1;
    final deepColor = colors.$2;

    final bgColor = isActive
        ? Colors.white.withValues(alpha: 0.18)
        : isDark
        ? accentColor.withValues(alpha: 0.12)
        : deepColor.withValues(alpha: 0.1);

    final icon = mobilePrayerIcons[prayerKey] ?? Icons.access_time_rounded;
    final iconColor = isActive
        ? Colors.white
        : isDark
        ? accentColor
        : deepColor;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Icon(icon, color: iconColor, size: contentSize),
    );
  }
}

class MobilePrayerInfo extends StatelessWidget {
  final String name;
  final bool isActive;

  const MobilePrayerInfo({
    super.key,
    required this.name,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: MobileTextStyles.titleMd(context).copyWith(
        fontSize: 19,
        color: isActive ? Colors.white : MobileColors.onSurface(context),
        height: 1.0,
      ),
    );
  }
}

class MobilePrayerTime extends StatelessWidget {
  final String timeText;
  final String? periodText;
  final bool isActive;
  final bool isCompact;

  const MobilePrayerTime({
    super.key,
    required this.timeText,
    required this.periodText,
    required this.isActive,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    final timeColor = isActive
        ? Colors.white
        : isDark
        ? MobileColors.onSurface(context)
        : const Color(0xFF1E293B);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          timeText,
          style: MobileTextStyles.titleMd(context).copyWith(
            fontSize: isCompact ? 18 : 22,
            color: timeColor,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (periodText != null) ...[
          const SizedBox(width: 4),
          Text(
            periodText!,
            style: MobileTextStyles.labelSm(context).copyWith(
              fontSize: 11,
              color: timeColor.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
