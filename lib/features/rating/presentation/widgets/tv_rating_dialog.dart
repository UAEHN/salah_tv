import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/i_rating_service.dart';
import '../../../settings/presentation/settings_screen.dart';
import 'tv_rating_action_button.dart';
import 'tv_rating_qr_panel.dart';

/// Landscape TV dialog: two QR codes (Play Store + Telegram) side by side.
/// Navigable via D-pad — "قيّمت" is auto-focused.
class TvRatingDialog extends StatelessWidget {
  const TvRatingDialog({super.key, required this.service});

  final IRatingService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TvRatingHeader(l: l),
            const SizedBox(height: 16),
            TvRatingQrPanel(
              url: AppConfig.playStoreUrl,
              icon: Icons.star_rounded,
              label: l.ratingDialogQrRate,
            ),
            const SizedBox(height: 16),
            _TvRatingActions(service: service),
          ],
        ),
      ),
    );
  }
}

class _TvRatingHeader extends StatelessWidget {
  const _TvRatingHeader({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Text(
      l.ratingDialogTitle,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TvRatingActions extends StatelessWidget {
  const _TvRatingActions({required this.service});

  final IRatingService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TvRatingActionButton(
          label: l.ratingDialogYes,
          autofocus: true,
          isPrimary: true,
          onPressed: () async {
            Navigator.of(context).pop();
            await service.markAsRated();
            final marketUri = Uri.parse(AppConfig.playStoreMarketUrl);
            final webUri = Uri.parse(AppConfig.playStoreUrl);
            final launched = await launchUrl(
              marketUri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              await launchUrl(webUri, mode: LaunchMode.externalApplication);
            }
          },
        ),
        const SizedBox(width: 20),
        TvRatingActionButton(
          label: l.ratingDialogSuggest,
          autofocus: false,
          isPrimary: false,
          onPressed: () async {
            Navigator.of(context).pop();
            await service.snooze();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(initialIndex: 7),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        TvRatingActionButton(
          label: l.ratingDialogLater,
          autofocus: false,
          isPrimary: false,
          onPressed: () async {
            Navigator.of(context).pop();
            await service.snooze();
          },
        ),
      ],
    );
  }
}
