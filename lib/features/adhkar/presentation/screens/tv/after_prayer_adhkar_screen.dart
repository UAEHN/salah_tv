import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import 'adhkar_takeover_screen.dart';

/// Thin wrapper: the after-prayer adhkar takeover is the generalized
/// [AdhkarTakeoverScreen] bound to the 'after_prayer' category. Kept as a named
/// screen so the home screen's call site (`AfterPrayerAdhkarScreen(palette:)`)
/// stays stable.
class AfterPrayerAdhkarScreen extends StatelessWidget {
  final AccentPalette palette;

  const AfterPrayerAdhkarScreen({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return AdhkarTakeoverScreen(
      palette: palette,
      categoryId: 'after_prayer',
      title: AppLocalizations.of(context).adhkarAfterPrayerTitle,
    );
  }
}
