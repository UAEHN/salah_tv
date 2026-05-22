import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';

/// Top bar for the qibla screen — theme-aware menu button + location chip.
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
    final isEn = l.localeName == 'en';
    final localizedCity = cityLabel(
      city,
      locale: l.localeName,
      countryKey: country,
    );
    final localizedCountry = countryLabel(country, locale: l.localeName);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundButton(
            icon: Icons.menu_rounded,
            onTap: () => MobileShell.switchTab(context, 0),
          ),
          _LocationChip(
            text: '$localizedCity${l.localeComma} $localizedCountry',
            isEn: isEn,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.65),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: MobileColors.border(context),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: MobileColors.onSurface(context).withValues(alpha: 0.85),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String text;
  final bool isEn;
  const _LocationChip({required this.text, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: MobileColors.border(context), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: MobileColors.onSurface(context),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.location_on_rounded,
            color: MobileColors.activePrimary(context),
            size: 14,
          ),
        ],
      ),
    );
  }
}
