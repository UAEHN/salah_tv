import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';
import '../../../../core/mobile_theme.dart';

/// Mobile-styled "update available" dialog. Tapping "تحديث الآن" opens
/// Google Play and dismisses the dialog. Tapping "لاحقاً" just dismisses it.
class MobileOptionalUpdateDialog extends StatelessWidget {
  const MobileOptionalUpdateDialog({
    super.key,
    required this.storeUrl,
    required this.messageAr,
    required this.onDismiss,
  });

  final String storeUrl;
  final String messageAr;
  final VoidCallback onDismiss;

  Future<void> _openStore(BuildContext context) async {
    final market = Uri.parse(AppConfig.playStoreMarketUrl);
    final web = Uri.parse(storeUrl);
    try {
      if (await canLaunchUrl(market)) {
        await launchUrl(market, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (context.mounted) onDismiss();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.system_update_alt_rounded,
                size: 40,
                color: MobileColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'يتوفر تحديث جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: MobileColors.onSurface(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                messageAr.isEmpty
                    ? 'يمكنك تحديث التطبيق الآن من متجر Google Play.'
                    : messageAr,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: MobileColors.onSurface(context).withValues(alpha: 0.75),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => _openStore(context),
                style: FilledButton.styleFrom(
                  backgroundColor: MobileColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'تحديث الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'لاحقاً',
                  style: TextStyle(
                    color: MobileColors.onSurface(context).withValues(alpha: 0.7),
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
