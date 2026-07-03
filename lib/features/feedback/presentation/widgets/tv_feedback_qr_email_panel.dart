import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_config.dart';
import '../../../../core/widgets/focus_scroll.dart';

/// Single focusable contact card for the TV feedback screen: Telegram + (when
/// configured) email QR codes side by side, sized to fit the viewport without
/// scrolling. Being one focus target keeps entering/leaving the section via the
/// settings nav reliable — D-pad right steps back out.
class TvFeedbackQrEmailPanel extends StatefulWidget {
  final String telegramCaption;
  final String emailCaption;
  final AccentPalette palette;
  final ThemeColors tc;

  const TvFeedbackQrEmailPanel({
    super.key,
    required this.telegramCaption,
    required this.emailCaption,
    required this.palette,
    required this.tc,
  });

  @override
  State<TvFeedbackQrEmailPanel> createState() => _TvFeedbackQrEmailPanelState();
}

class _TvFeedbackQrEmailPanelState extends State<TvFeedbackQrEmailPanel> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final tc = widget.tc;
    final telegramUrl = AppConfig.supportTelegramUrl;
    final telegramTarget = telegramUrl.isNotEmpty
        ? telegramUrl
        : AppConfig.tvFeedbackUrl;
    final hasEmail = AppConfig.supportEmail.isNotEmpty;

    return Focus(
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: tc
            .glass(opacity: 0.07, borderRadius: 20)
            .copyWith(
              border: Border.all(
                color: _isFocused ? p.primary : tc.borderGlass,
                width: _isFocused ? 2.5 : 1,
              ),
              boxShadow: _isFocused
                  ? [BoxShadow(color: p.glow, blurRadius: 18, spreadRadius: 1)]
                  : null,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _QrTile(
                    data: telegramTarget,
                    icon: Icons.send_rounded,
                    caption: widget.telegramCaption,
                    palette: p,
                    tc: tc,
                  ),
                ),
                if (hasEmail) ...[
                  Container(width: 1, height: 160, color: tc.borderGlass),
                  Expanded(
                    child: _QrTile(
                      data: 'mailto:${AppConfig.supportEmail}',
                      icon: Icons.email_rounded,
                      caption: widget.emailCaption,
                      palette: p,
                      tc: tc,
                    ),
                  ),
                ],
              ],
            ),
            if (hasEmail) ...[
              const SizedBox(height: 14),
              Text(
                AppConfig.supportEmail,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: p.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QrTile extends StatelessWidget {
  final String data;
  final IconData icon;
  final String caption;
  final AccentPalette palette;
  final ThemeColors tc;

  const _QrTile({
    required this.data,
    required this.icon,
    required this.caption,
    required this.palette,
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
            size: 140,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(height: 12),
        Icon(icon, color: palette.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: tc.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
