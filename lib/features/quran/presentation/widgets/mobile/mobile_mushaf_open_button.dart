import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';

/// Primary CTA on the Mushaf landing screen — opens the reader at page 1.
/// Gradient is built from the active palette's primary so it follows
/// theme changes (unlike the static `activePillCard` in MobileDecorations).
class MobileMushafOpenButton extends StatelessWidget {
  final VoidCallback onTap;
  const MobileMushafOpenButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final lighter = Color.lerp(primary, Colors.white, 0.22) ?? primary;
    final isDark = MobileColors.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [primary, lighter],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.35 : 0.28),
                offset: const Offset(0, 8),
                blurRadius: 18,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).mushafOpenFromStart,
                style: MobileTextStyles.headlineMd(context).copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
