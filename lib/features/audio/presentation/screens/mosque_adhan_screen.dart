import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import 'mosque_announcement_screen.dart';

/// Full-screen visual takeover used in mosque mode when prayer time arrives.
/// No audio (the muezzin handles it). Static — no pulse animation.
class MosqueAdhanScreen extends StatelessWidget {
  final String prayerName;
  final AccentPalette palette;

  const MosqueAdhanScreen({
    required this.prayerName,
    required this.palette,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefix = _splitPrefix(l.mosqueAdhanNowTitle(prayerName), prayerName);
    return MosqueAnnouncementScreen(
      label: prefix,
      prayerName: prayerName,
      palette: palette,
    );
  }

  /// "حان الآن موعد أذان الفجر" → "حان الآن موعد أذان". Strips the localized
  /// prayer name so it can be rendered separately with its own typography.
  String _splitPrefix(String full, String prayerName) {
    final i = full.lastIndexOf(prayerName);
    if (i <= 0) return full;
    return full.substring(0, i).trim();
  }
}
