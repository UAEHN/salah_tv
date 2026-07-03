import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';
import '../../../../quran/domain/khatma_calculator.dart';
import '../../../../quran/presentation/bloc/khatma_cubit.dart';
import '../../../../quran/presentation/bloc/khatma_state.dart';
import '../../../../quran/presentation/widgets/mobile/khatma_ring.dart';
import '../../../../quran/presentation/widgets/mobile/mushaf_arabic_digits.dart';
import 'bento_tile.dart';

/// «ختمة القرآن» shortcut on the Today screen. Shows live progress when a
/// plan is active, a celebratory line when complete, and a start CTA when
/// there's none — so the feature is discoverable from the home canvas.
/// Reads the hoisted `KhatmaCubit` (CLAUDE.md §6 widget-tree access).
class BentoKhatmaTile extends StatelessWidget {
  const BentoKhatmaTile({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<KhatmaCubit>().state;
    if (!state.isLoaded) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => MobileShell.openKhatma(context),
        child: BentoTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          radius: 22,
          child: _content(context, state),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, KhatmaState state) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final surface = BentoSurface.of(context);
    final k = state.khatma;

    if (k == null) {
      // No active plan → start CTA.
      return Row(
        children: [
          _circleIcon(accent, Icons.auto_stories_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l.khatmaStartCta,
              style: MobileTextStyles.headlineMd(context).copyWith(
                color: surface.foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: surface.foregroundMuted),
        ],
      );
    }

    final percent = (KhatmaCalculator.progressFraction(k) * 100).round();
    final todayLeft = KhatmaCalculator.todayRemaining(k, DateTime.now());
    final subtitle = state.isCompleted
        ? l.khatmaTodayDone
        : (todayLeft <= 0
              ? l.khatmaTodayDone
              : l.khatmaPagesLeftToday(digitsForLocale(context, todayLeft)));

    return Row(
      children: [
        KhatmaRing(
          fraction: KhatmaCalculator.progressFraction(k),
          size: 46,
          strokeWidth: 5,
          center: Text(
            digitsForLocale(context, percent),
            style: MobileTextStyles.labelSm(context).copyWith(
              fontSize: 11,
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.khatmaTitle,
                style: MobileTextStyles.headlineMd(context).copyWith(
                  color: surface.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: MobileTextStyles.bodyMd(
                  context,
                ).copyWith(color: surface.foregroundMuted),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_left_rounded, color: surface.foregroundMuted),
      ],
    );
  }

  Widget _circleIcon(Color accent, IconData icon) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.16),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: accent, size: 22),
  );
}
