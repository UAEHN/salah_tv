import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import 'tv_open_store_button.dart';

/// Blocking "must update" dialog — wraps content in [PopScope] with
/// `canPop: false` so the back button cannot dismiss it. The user can only
/// press the update button to leave for Google Play.
class TvForceUpdateDialog extends StatelessWidget {
  const TvForceUpdateDialog({
    super.key,
    required this.storeUrl,
    required this.messageAr,
  });

  final String storeUrl;
  final String messageAr;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(true);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 160, vertical: 60),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A).withValues(alpha: 0.99),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.system_update_alt_rounded,
                  size: 52,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 18),
                Text(
                  'تحديث مطلوب',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: tc.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  messageAr.isEmpty
                      ? 'هذه النسخة لم تعد مدعومة. يرجى تحديث التطبيق للاستمرار.'
                      : messageAr,
                  style: TextStyle(
                    fontSize: 16,
                    color: tc.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TvOpenStoreButton(
                  storeUrl: storeUrl,
                  label: 'تحديث',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
