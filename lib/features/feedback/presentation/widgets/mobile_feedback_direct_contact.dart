import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_config.dart';
import '../../../../core/mobile_theme.dart';
import '../../../../core/platform_launcher.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../domain/i_feedback_diagnostics_collector.dart';
import '../logic/feedback_contact_payload.dart';
import 'mobile_feedback_contact_tile.dart';

/// Direct-contact tiles (email + Telegram). Both tiles pre-fill the same
/// diagnostic block the in-app form attaches automatically, so users who
/// reach us via direct email/Telegram still give us enough context.
///
/// - Email: opens `mailto:` with subject + body filled.
/// - Telegram: copies the diagnostics to the clipboard then opens the chat.
///   Telegram URLs don't accept pre-filled text in user-to-user chats, so
///   clipboard is the closest equivalent we can offer.
class MobileFeedbackDirectContact extends StatelessWidget {
  final String title;
  final String emailLabel;
  final String telegramLabel;

  const MobileFeedbackDirectContact({
    super.key,
    required this.title,
    required this.emailLabel,
    required this.telegramLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasEmail = AppConfig.supportEmail.isNotEmpty;
    final hasTelegram = AppConfig.supportTelegramUrl.isNotEmpty;
    if (!hasEmail && !hasTelegram) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MobileTextStyles.bodyMd(context).copyWith(
            color: MobileColors.onSurfaceMuted(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        if (hasEmail)
          MobileFeedbackContactTile(
            icon: Icons.email_rounded,
            label: emailLabel,
            value: AppConfig.supportEmail,
            onTap: () => _openEmail(context),
          ),
        if (hasEmail && hasTelegram) const SizedBox(height: 10),
        if (hasTelegram)
          MobileFeedbackContactTile(
            icon: Icons.send_rounded,
            label: telegramLabel,
            onTap: () => _openTelegram(context),
          ),
      ],
    );
  }

  Future<String> _buildDiagnosticBody(BuildContext context) async {
    final diagnostics =
        await GetIt.I<IFeedbackDiagnosticsCollector>().collect();
    if (!context.mounted) return '';
    final l = AppLocalizations.of(context);
    final settings = context.read<SettingsProvider>().settings;
    return buildFeedbackContactMessage(
      diagnostics: diagnostics,
      settings: settings,
      userPrompt: l.feedbackEmailBodyPrompt,
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final body = await _buildDiagnosticBody(context);
    if (!context.mounted) return;
    final subject = AppLocalizations.of(context).feedbackEmailSubject;
    final uri = buildMailtoUri(
      email: AppConfig.supportEmail,
      subject: subject,
      body: body,
    );
    await PlatformLauncher.openUrl(uri);
  }

  Future<void> _openTelegram(BuildContext context) async {
    final body = await _buildDiagnosticBody(context);
    if (!context.mounted) return;
    await Clipboard.setData(ClipboardData(text: body));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).feedbackTelegramCopiedToast),
        duration: const Duration(seconds: 4),
      ),
    );
    await PlatformLauncher.openUrl(AppConfig.supportTelegramUrl);
  }
}
