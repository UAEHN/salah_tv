import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';
import '../../../../core/mobile_theme.dart';

/// Mobile-styled blocking "must update" dialog. `PopScope(canPop: false)`
/// prevents the back button from dismissing it — the only way out is to
/// tap the update button (which leaves the app for Google Play).
class MobileForceUpdateDialog extends StatelessWidget {
  const MobileForceUpdateDialog({
    super.key,
    required this.storeUrl,
    required this.messageAr,
  });

  final String storeUrl;
  final String messageAr;

  Future<void> _openStore() async {
    final market = Uri.parse(AppConfig.playStoreMarketUrl);
    final web = Uri.parse(storeUrl);
    try {
      if (await canLaunchUrl(market)) {
        await launchUrl(market, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: MobileColors.cardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.system_update_alt_rounded,
                  size: 44,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 14),
                Text(
                  'تحديث مطلوب',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MobileColors.onSurface(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  messageAr.isEmpty
                      ? 'هذه النسخة لم تعد مدعومة. يرجى تحديث التطبيق للاستمرار.'
                      : messageAr,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        MobileColors.onSurface(context).withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _openStore,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'تحديث',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
