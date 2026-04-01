import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';

/// Minimal header: location pill in the center, menu icon on the right.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onLocationTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: MobileColors.cardColor(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MobileColors.border(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: MobileColors.primaryContainer,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$city${l.localeComma} $country',
                        style: MobileTextStyles.labelSm(
                          context,
                        ).copyWith(color: MobileColors.onSurfaceMuted(context)),
                        textDirection: TextDirection.rtl,
                      ),
                      if (onLocationTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.expand_more_rounded,
                          color: MobileColors.onSurfaceMuted(context),
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              color: MobileColors.primaryContainer,
              iconSize: 28,
              onPressed: () => MobileShell.switchTab(context, 0),
            ),
          ),
        ],
      ),
    );
  }
}
