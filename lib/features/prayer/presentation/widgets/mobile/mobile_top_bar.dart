import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';

/// Header bar: location pill (center) with glowing pin, menu icon (right).
class MobileTopBar extends StatelessWidget {
  final String city;
  final String country;
  final VoidCallback? onLocationTap;

  const MobileTopBar({
    super.key,
    required this.city,
    required this.country,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = MobileColors.isDark(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Location pill
          GestureDetector(
            onTap: onLocationTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: MobileColors.cardColor(context).withValues(
                      alpha: isDark ? 0.45 : 0.7,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: MobileColors.border(context).withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing location pin
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MobileColors.primaryContainer.withValues(
                            alpha: 0.15,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: MobileColors.primaryContainer,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$city${l.localeComma} $country',
                        style: MobileTextStyles.labelSm(context).copyWith(
                          color: MobileColors.onSurface(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      if (onLocationTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.expand_more_rounded,
                          color: MobileColors.onSurfaceMuted(context),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Menu icon
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => MobileShell.switchTab(context, 0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MobileColors.cardColor(context).withValues(
                    alpha: isDark ? 0.3 : 0.5,
                  ),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: MobileColors.onSurfaceMuted(context),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
