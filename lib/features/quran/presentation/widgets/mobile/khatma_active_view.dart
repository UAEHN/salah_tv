import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../today/presentation/widgets/bento/bento_tile.dart';
import '../../../domain/entities/khatma_plan.dart';
import '../../../domain/khatma_calculator.dart';
import '../../bloc/khatma_cubit.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../screens/mobile/mobile_mushaf_reader_screen.dart';
import 'khatma_progress_bar.dart';
import 'mushaf_arabic_digits.dart';

/// Active-Khatma body: overall progress bar + stats + today's wird card.
/// Derived values come from [KhatmaCalculator] (no math in the widget). The
/// wird card opens the reader constrained to today's pages.
class KhatmaActiveView extends StatelessWidget {
  final Khatma khatma;

  const KhatmaActiveView({super.key, required this.khatma});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final now = DateTime.now();
    final percent = (KhatmaCalculator.progressFraction(khatma) * 100).round();
    final daysLeft = KhatmaCalculator.daysRemaining(khatma, now);
    final streak = KhatmaCalculator.currentStreak(khatma, now);
    final todayLeft = KhatmaCalculator.todayRemaining(khatma, now);
    final wird = KhatmaCalculator.todayWird(khatma, now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${digitsForLocale(context, percent)}٪',
              style: MobileTextStyles.titleMd(context).copyWith(color: accent),
            ),
            Text(
              l.khatmaPagesOfTotal(
                digitsForLocale(context, khatma.readCount),
                digitsForLocale(context, khatma.totalPages),
              ),
              style: MobileTextStyles.bodyMd(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        KhatmaProgressBar(fraction: KhatmaCalculator.progressFraction(khatma)),
        const SizedBox(height: 18),
        Row(
          children: [
            _StatChip(
              icon: Icons.event_rounded,
              label: l.khatmaDaysLeft(digitsForLocale(context, daysLeft)),
            ),
            const SizedBox(width: 10),
            _StatChip(
              icon: Icons.local_fire_department_rounded,
              label: l.khatmaStreakLabel(digitsForLocale(context, streak)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _WirdCard(wird: wird, isDoneToday: todayLeft <= 0),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Expanded(
      child: BentoTile(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        radius: 18,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: MobileTextStyles.bodyMd(context).copyWith(
                  color: BentoSurface.of(context).foreground,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WirdCard extends StatelessWidget {
  final KhatmaWird? wird;
  final bool isDoneToday;
  const _WirdCard({required this.wird, required this.isDoneToday});

  Future<void> _openWird(BuildContext context, KhatmaWird w) async {
    final reader = context.read<MushafReaderCubit>();
    final khatma = context.read<KhatmaCubit>();
    final navigator = Navigator.of(context);
    await reader.openReader(page: w.first);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: reader,
          child: MobileMushafReaderScreen(
            wird: w,
            onWirdComplete: () => khatma.completeWird(w),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final w = wird;
    return BentoTile(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDoneToday ? l.khatmaTodayDone : l.khatmaTodayPortion,
            style: MobileTextStyles.headlineMd(context).copyWith(
              color: BentoSurface.of(context).foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (w != null) ...[
            const SizedBox(height: 6),
            Text(
              l.khatmaWirdRangeLabel(
                digitsForLocale(context, w.first),
                digitsForLocale(context, w.last),
              ),
              style: MobileTextStyles.bodyMd(context),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _openWird(context, w),
                icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
                label: Text(
                  isDoneToday ? l.khatmaReadAhead : l.khatmaReadWird,
                  style: MobileTextStyles.headlineMd(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
