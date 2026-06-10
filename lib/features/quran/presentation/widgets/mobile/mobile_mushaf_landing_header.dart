import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';

/// Title block at the top of the Mushaf landing screen.
///
/// Just the page title plus a small theme-accent line beneath it — the
/// stat chips (114 surahs / 30 juz / 604 pages) were removed because they
/// added noise without giving the user anything they could act on.
class MobileMushafLandingHeader extends StatelessWidget {
  const MobileMushafLandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).mushafLandingTitle,
            textAlign: TextAlign.center,
            style: MobileTextStyles.titleMd(
              context,
            ).copyWith(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            width: 56,
            height: 3,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
