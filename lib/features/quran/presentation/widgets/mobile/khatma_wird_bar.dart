import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../../domain/khatma_calculator.dart';
import 'mushaf_arabic_digits.dart';

/// Bottom bar shown in the reader's wird mode. Displays the position within
/// today's wird and offers «أتممت الورد» — enabled only once the reader
/// reaches the last page of the wird, matching the deliberate "finish then
/// confirm" flow.
class KhatmaWirdBar extends StatelessWidget {
  final int currentPage;
  final KhatmaWird wird;
  final ReadingPalette palette;
  final VoidCallback onComplete;

  const KhatmaWirdBar({
    super.key,
    required this.currentPage,
    required this.wird,
    required this.palette,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final total = wird.last - wird.first + 1;
    final pos = (currentPage - wird.first + 1).clamp(1, total);
    final atEnd = currentPage >= wird.last;
    return Container(
      color: palette.screenBg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.khatmaPagesOfTotal(
                digitsForLocale(context, pos),
                digitsForLocale(context, total),
              ),
              style: MobileTextStyles.labelSm(
                context,
              ).copyWith(color: palette.appBarFg.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: atEnd
                      ? accent
                      : accent.withValues(alpha: 0.30),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: atEnd ? onComplete : null,
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  atEnd ? l.khatmaCompleteWird : l.khatmaWirdHint,
                  style: MobileTextStyles.headlineMd(
                    context,
                  ).copyWith(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
