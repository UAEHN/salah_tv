import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import 'mosque_announcement_screen.dart';

/// Mosque-mode iqama visual takeover. Mirrors [MosqueAdhanScreen] styling:
/// minimal typography, no card, no icon. Held for 30 s by the engine.
class MosqueIqamaScreen extends StatelessWidget {
  final String prayerName;
  final AccentPalette palette;

  const MosqueIqamaScreen({
    required this.prayerName,
    required this.palette,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MosqueAnnouncementScreen(
      label: l.mosqueIqamaLabel,
      prayerName: prayerName,
      palette: palette,
      labelBelow: false,
    );
  }
}
