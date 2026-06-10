import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_config.dart';

/// Right-side panel of the TV feedback screen.
///
/// Two QR codes side-by-side — Telegram and (when an email is configured)
/// `mailto:` — so the entire panel fits within the TV viewport without
/// needing a scrollable region (the TV screen has no scroll affordance).
///
/// Theme-aware: pass [tc] so labels render with proper contrast in light mode.
class TvFeedbackQrEmailPanel extends StatelessWidget {
  final String title;
  final String telegramCaption;
  final String emailCaption;
  final String orFromPhoneLabel;
  final ThemeColors tc;

  const TvFeedbackQrEmailPanel({
    super.key,
    required this.title,
    required this.telegramCaption,
    required this.emailCaption,
    required this.orFromPhoneLabel,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final telegramUrl = AppConfig.supportTelegramUrl;
    final telegramTarget = telegramUrl.isNotEmpty
        ? telegramUrl
        : AppConfig.tvFeedbackUrl;
    final hasEmail = AppConfig.supportEmail.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: tc
          .glass(opacity: 0.07, borderRadius: 20)
          .copyWith(border: Border.all(color: tc.borderGlass)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: tc.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _QrTile(
                  data: telegramTarget,
                  icon: Icons.send_rounded,
                  caption: telegramCaption,
                  tc: tc,
                ),
              ),
              if (hasEmail) ...[
                const SizedBox(width: 24),
                Container(width: 1, height: 200, color: tc.borderGlass),
                const SizedBox(width: 24),
                Expanded(
                  child: _QrTile(
                    data: 'mailto:${AppConfig.supportEmail}',
                    icon: Icons.email_rounded,
                    caption: emailCaption,
                    tc: tc,
                  ),
                ),
              ],
            ],
          ),
          if (hasEmail) ...[
            const SizedBox(height: 24),
            Text(
              orFromPhoneLabel,
              style: TextStyle(color: tc.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              AppConfig.supportEmail,
              style: TextStyle(
                color: tc.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _QrTile extends StatelessWidget {
  final String data;
  final IconData icon;
  final String caption;
  final ThemeColors tc;

  const _QrTile({
    required this.data,
    required this.icon,
    required this.caption,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(height: 12),
        Icon(icon, color: Colors.amber, size: 22),
        const SizedBox(height: 4),
        Text(
          caption,
          style: TextStyle(
            color: tc.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
