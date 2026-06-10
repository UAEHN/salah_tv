import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../logic/reciter_list_sorter.dart';

/// Section title rendered between reciter groups (favorites / all) in the
/// picker. Non-focusable; D-pad scrolls past it.
class ReciterSectionLabel extends StatelessWidget {
  final ReciterSection section;
  final Color accent;
  const ReciterSectionLabel({
    required this.section,
    required this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = section == ReciterSection.favorites
        ? l.reciterFavoritesSection
        : l.reciterAllSection;
    final icon = section == ReciterSection.favorites
        ? Icons.star_rounded
        : Icons.list_rounded;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 14, 4, 6),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection-error state for [ReciterPickerDialog].
class ReciterErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final AccentPalette palette;
  const ReciterErrorView({
    required this.onRetry,
    required this.palette,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(
            l.settingsFailedToLoadReciters,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 17),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l.commonRetry,
              style: TextStyle(color: palette.primary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state shown while reciters are fetched.
class ReciterLoadingView extends StatelessWidget {
  final AccentPalette palette;
  const ReciterLoadingView({required this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: palette.primary),
          const SizedBox(height: 16),
          Text(
            l.settingsLoadingReciters,
            style: const TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
