import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/khatma_cubit.dart';
import 'khatma_create_sheet.dart';

/// Shown when the Khatma reaches 100%. Congratulates the reader, shows the
/// du'a of completing the Quran, and offers to start a fresh Khatma.
///
/// A Lottie celebration can be dropped in later (the `lottie` package is
/// already a dependency) — kept as a clean medallion for now so the feature
/// ships without waiting on an asset.
class KhatmaCompleteView extends StatelessWidget {
  final KhatmaCubit cubit;
  const KhatmaCompleteView({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_rounded, color: accent, size: 52),
            ),
            const SizedBox(height: 22),
            Text(
              l.khatmaCompletedTitle,
              textAlign: TextAlign.center,
              style: MobileTextStyles.titleMd(context),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withValues(alpha: 0.20)),
              ),
              child: Text(
                l.khatmaCompletedDua,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 20,
                  height: 1.9,
                  color: MobileColors.onSurface(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => KhatmaCreateSheet.show(context, cubit),
                child: Text(
                  l.khatmaCreateTitle,
                  style: MobileTextStyles.headlineMd(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
