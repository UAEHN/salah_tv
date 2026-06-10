import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import '../widgets/adhan_offsets_table.dart';

/// TV-friendly route that exposes the existing [AdhanOffsetsTable] in its
/// own page so the post-method-pick calibration prompt has somewhere to
/// land. The same table is also accessible from the main TV settings.
class TvPrayerOffsetsScreen extends StatelessWidget {
  const TvPrayerOffsetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    return Scaffold(
      backgroundColor: tc.bgSurface,
      appBar: AppBar(
        backgroundColor: tc.bgSurface,
        iconTheme: IconThemeData(color: tc.textPrimary),
        title: Text(
          l.settingsAdjustTimes,
          style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.settingsAdjustAdhanTimeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tc.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              const AdhanOffsetsTable(),
            ],
          ),
        ),
      ),
    );
  }
}
