import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'tv_feedback_qr_email_panel.dart';

/// TV feedback screen — direct-contact ONLY (Telegram + email via QR).
///
/// The in-app note form was removed deliberately: on TV, users typed empty or
/// vague notes with no real contact channel, producing unactionable noise with
/// no way to follow up. Routing every report through Telegram/email (scanned
/// from the phone) guarantees a real two-way channel.
///
/// Layout note: the contact cards are D-pad focusable and scroll themselves
/// into view, so on a small TV viewport nothing is hidden below the fold and
/// the user can always step back out to the settings nav.
class TvFeedbackSection extends StatelessWidget {
  const TvFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final palette = getThemePalette(settings.themeColorKey);

    return Center(
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: palette.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.feedbackTitle,
              style: TextStyle(
                color: tc.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l.feedbackSubtitle,
              style: TextStyle(fontSize: 15, color: tc.textMuted, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TvFeedbackQrEmailPanel(
              telegramCaption: l.feedbackTvQrTelegram,
              emailCaption: l.feedbackTvQrEmail,
              palette: palette,
              tc: tc,
            ),
          ],
        ),
      ),
    );
  }
}
