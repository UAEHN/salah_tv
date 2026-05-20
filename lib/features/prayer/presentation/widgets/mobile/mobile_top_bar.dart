import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
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
    final isEn = l.localeName == 'en';
    final localizedCity = cityLabel(
      city,
      locale: l.localeName,
      countryKey: country,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Location pill
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: MobileColors.cardColor(
                  context,
                ).withValues(alpha: isDark ? 0.88 : 0.92),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: MobileColors.border(
                    context,
                  ).withValues(alpha: 0.5),
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
                          color: MobileColors.activePrimaryContainer(
                            context,
                          ).withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: MobileColors.activePrimaryContainer(context),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizedCity,
                        style: MobileTextStyles.labelSm(context).copyWith(
                          color: MobileColors.onSurface(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: isEn
                            ? TextDirection.ltr
                            : TextDirection.rtl,
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
                  color: MobileColors.cardColor(
                    context,
                  ).withValues(alpha: isDark ? 0.3 : 0.5),
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
