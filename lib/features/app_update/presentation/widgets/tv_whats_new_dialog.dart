import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'tv_dialog_dismiss_button.dart';

/// TV-specific "What's New" dialog — glassmorphism design.
/// Uses [ThemeColors] only; never imports MobileColors.
/// Navigable via D-Pad (single dismiss button is auto-focused).
class TvWhatsNewDialog extends StatelessWidget {
  const TvWhatsNewDialog({
    super.key,
    required this.changelog,
    required this.onDismiss,
  });

  final List<String> changelog;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // TV is always displayed in dark mode.
    final tc = ThemeColors.of(true);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l.whatsNewTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _TvChangelogList(changelog: changelog, tc: tc),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
              child: TvDialogDismissButton(
                label: l.whatsNewDismiss,
                onPressed: onDismiss,
                tc: tc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Changelog list ───────────────────────────────────────────────────────────

class _TvChangelogList extends StatelessWidget {
  const _TvChangelogList({required this.changelog, required this.tc});

  final List<String> changelog;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changelog
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: tc.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
