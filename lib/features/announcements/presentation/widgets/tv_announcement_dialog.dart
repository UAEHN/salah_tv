import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_colors.dart';
import '../../../app_update/presentation/widgets/tv_dialog_dismiss_button.dart';
import '../../domain/entities/announcement.dart';

/// TV-styled broadcast announcement dialog. Mirrors `TvOptionalUpdateDialog`
/// for visual parity. The CTA button only appears when the announcement
/// includes a non-empty `ctaUrl`.
class TvAnnouncementDialog extends StatelessWidget {
  const TvAnnouncementDialog({
    super.key,
    required this.announcement,
    required this.onDismiss,
  });

  final Announcement announcement;
  final VoidCallback onDismiss;

  Future<void> _openCta(BuildContext context) async {
    final uri = Uri.tryParse(announcement.ctaUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (context.mounted) onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(true);
    final hasCta = announcement.hasCta;
    final locale = Localizations.localeOf(context).languageCode;
    final title = announcement.localizedTitle(locale);
    final body = announcement.localizedBody(locale);
    final ctaLabel = announcement.localizedCtaLabel(locale);
    final isEnglish = locale == 'en';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 160, vertical: 60),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.campaign_rounded,
                size: 44,
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 14),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (title.isNotEmpty) const SizedBox(height: 12),
              if (body.isNotEmpty)
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 16,
                    color: tc.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (hasCta)
                Builder(
                  builder: (ctx) => TvDialogDismissButton(
                    label: ctaLabel.isEmpty
                        ? (isEnglish ? 'Open link' : 'فتح الرابط')
                        : ctaLabel,
                    onPressed: () => _openCta(ctx),
                    tc: tc,
                  ),
                ),
              if (hasCta) const SizedBox(height: 12),
              TvDialogDismissButton(
                label: hasCta
                    ? (isEnglish ? 'Close' : 'إغلاق')
                    : (isEnglish ? 'OK' : 'حسناً'),
                onPressed: onDismiss,
                tc: tc,
                autofocus: !hasCta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
