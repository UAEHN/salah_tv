import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

class MobileSettingsHeader extends StatelessWidget {
  const MobileSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            l.navSettings,
            style: MobileTextStyles.titleMd(
              context,
            ).copyWith(color: MobileColors.onSurface(context), fontSize: 24),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: MobileColors.onSurface(context),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
    );
  }
}
