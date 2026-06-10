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
/// from the phone) guarantees a real two-way channel. The contact-only panel
/// now fills the whole settings slot instead of sharing it with a text form.
class TvFeedbackSection extends StatelessWidget {
  const TvFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.feedbackTitle,
              style: TextStyle(
                color: tc.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l.feedbackSubtitle,
              style: TextStyle(fontSize: 17, color: tc.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TvFeedbackQrEmailPanel(
              title: l.feedbackTvDirectTitle,
              telegramCaption: l.feedbackTvQrTelegram,
              emailCaption: l.feedbackTvQrEmail,
              orFromPhoneLabel: l.feedbackTvOrFromPhone,
              tc: tc,
            ),
          ],
        ),
      ),
    );
  }
}
