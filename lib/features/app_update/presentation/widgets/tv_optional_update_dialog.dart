import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import 'tv_dialog_dismiss_button.dart';
import 'tv_open_store_button.dart';

/// Soft "update available" dialog — dismissible. Shown when the installed
/// build is below `latestVersionCode` but at or above `minSupportedVersionCode`.
class TvOptionalUpdateDialog extends StatelessWidget {
  const TvOptionalUpdateDialog({
    super.key,
    required this.storeUrl,
    required this.messageAr,
    required this.onDismiss,
  });

  final String storeUrl;
  final String messageAr;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(true);

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
                Icons.system_update_alt_rounded,
                size: 44,
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 14),
              Text(
                'يتوفر تحديث جديد',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                messageAr.isEmpty
                    ? 'يمكنك تحديث التطبيق الآن من متجر Google Play.'
                    : messageAr,
                style: TextStyle(
                  fontSize: 16,
                  color: tc.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (ctx) => TvOpenStoreButton(
                  storeUrl: storeUrl,
                  label: 'تحديث الآن',
                  onAfterLaunch: () {
                    if (Navigator.of(ctx).canPop()) {
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TvDialogDismissButton(
                label: 'لاحقاً',
                onPressed: onDismiss,
                tc: tc,
                autofocus: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
