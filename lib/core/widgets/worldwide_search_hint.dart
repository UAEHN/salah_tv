import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

/// Small, always-visible discoverability line that tells the user they can
/// type to search for any city worldwide when their country/city isn't in the
/// listed options. Reuses the existing `settingsSearchOnlineCta` string so the
/// wording stays consistent across the settings picker and first-run
/// onboarding (CLAUDE.md §4 DRY).
class WorldwideSearchHint extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  final EdgeInsetsGeometry padding;

  const WorldwideSearchHint({
    required this.textColor,
    required this.accentColor,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore_rounded, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l.settingsSearchOnlineCta,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
