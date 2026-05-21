import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';

/// Centered failure view for the Mushaf landing screen — extracted to
/// keep the screen file under 150 lines.
class MobileMushafErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const MobileMushafErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: MobileColors.onSurfaceMuted(context),
          ),
          const SizedBox(height: 12),
          Text(message, style: MobileTextStyles.bodyMd(context)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}
