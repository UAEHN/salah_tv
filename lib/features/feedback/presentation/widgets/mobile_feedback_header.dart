import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';

class MobileFeedbackHeader extends StatelessWidget {
  final AppLocalizations l;

  const MobileFeedbackHeader({super.key, required this.l});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: MobileColors.onSurface(context),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.feedbackTitle,
              style: MobileTextStyles.headlineMd(
                context,
              ).copyWith(fontSize: 20),
            ),
            Text(
              l.feedbackSubtitle,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurfaceMuted(context),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
