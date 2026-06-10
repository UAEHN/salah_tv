import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';
import '../../../../core/mobile_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/i_rating_service.dart';
import 'rating_dialog_body.dart';

/// Dialog asking the user to rate the app.
/// Three paths:
///   "أحب التطبيق" → Google Play → marks rated.
///   "اقتراح"      → /feedback route → snoozes 30 days.
///   "لاحقاً"      → dismiss → snoozes 14 days.
class RatingDialog extends StatelessWidget {
  const RatingDialog({super.key, required this.service});

  final IRatingService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = MobileColors.isDark(context);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RatingDialogHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Text(
                l.ratingDialogTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: MobileColors.onSurface(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            RatingPrimaryButton(
              label: l.ratingDialogYes,
              onTap: () => _onRate(context),
            ),
            const SizedBox(height: 10),
            RatingSecondaryButton(
              label: l.ratingDialogSuggest,
              onTap: () => _onSuggest(context),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _onLater(context),
              child: Text(
                l.ratingDialogLater,
                style: TextStyle(
                  color: MobileColors.onSurfaceMuted(context),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _onRate(BuildContext context) async {
    Navigator.of(context).pop();
    await service.markAsRated();
    final market = Uri.parse(AppConfig.playStoreMarketUrl);
    if (await canLaunchUrl(market)) {
      await launchUrl(market);
    } else {
      await launchUrl(
        Uri.parse(AppConfig.playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _onSuggest(BuildContext context) async {
    Navigator.of(context).pop();
    await service.snoozeLong();
    if (context.mounted) {
      Navigator.of(context).pushNamed('/feedback');
    }
  }

  Future<void> _onLater(BuildContext context) async {
    Navigator.of(context).pop();
    await service.snooze();
  }
}
