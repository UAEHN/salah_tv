import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/mobile_theme.dart';
import '../../domain/entities/announcement.dart';

/// Mobile-styled broadcast announcement dialog. Mirrors
/// `MobileOptionalUpdateDialog` so visual language stays consistent.
class MobileAnnouncementDialog extends StatelessWidget {
  const MobileAnnouncementDialog({
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
    final isDark = MobileColors.isDark(context);
    final hasCta = announcement.hasCta;
    final locale = Localizations.localeOf(context).languageCode;
    final title = announcement.localizedTitle(locale);
    final body = announcement.localizedBody(locale);
    final ctaLabel = announcement.localizedCtaLabel(locale);
    final isEnglish = locale == 'en';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: MobileColors.cardColor(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.campaign_rounded,
                size: 40,
                color: MobileColors.primary,
              ),
              const SizedBox(height: 12),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: MobileColors.onSurface(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              if (title.isNotEmpty) const SizedBox(height: 10),
              if (body.isNotEmpty)
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: MobileColors.onSurface(
                      context,
                    ).withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 22),
              if (hasCta)
                FilledButton(
                  onPressed: () => _openCta(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: MobileColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    ctaLabel.isEmpty
                        ? (isEnglish ? 'Open link' : 'فتح الرابط')
                        : ctaLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (hasCta) const SizedBox(height: 8),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  hasCta
                      ? (isEnglish ? 'Close' : 'إغلاق')
                      : (isEnglish ? 'OK' : 'حسناً'),
                  style: TextStyle(
                    color: MobileColors.onSurface(
                      context,
                    ).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
