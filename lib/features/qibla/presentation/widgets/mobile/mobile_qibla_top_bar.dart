import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';

class MobileQiblaTopBar extends StatelessWidget {
  final String city;
  final String country;

  const MobileQiblaTopBar({
    super.key,
    required this.city,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: MobileColors.cardColor(context).withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: MobileColors.border(context)),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              color: MobileColors.onSurface(context),
              iconSize: 20,
              onPressed: () => MobileShell.switchTab(context, 0),
            ),
          ),
          ClipRRect(
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
                    Text(
                      '$city${l.localeComma} $country',
                      style: MobileTextStyles.labelSm(context).copyWith(
                        color: MobileColors.onSurface(context),
                        fontSize: 12,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on,
                      color: MobileColors.primaryContainer,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
