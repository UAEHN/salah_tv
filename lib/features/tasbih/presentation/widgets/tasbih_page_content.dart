import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/localization/tasbih_text_localizer.dart';
import '../../../../core/mobile_theme.dart';
import '../../domain/entities/tasbih_preset.dart';
import '../bloc/tasbih_bloc.dart';
import '../bloc/tasbih_event.dart';
import '../bloc/tasbih_state.dart';
import 'tasbih_counter_display.dart';
import 'tasbih_page_indicator.dart';

class TasbihPageContent extends StatelessWidget {
  final int presetIndex;

  const TasbihPageContent({super.key, required this.presetIndex});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final preset = kTasbihPresets[presetIndex];

    return BlocBuilder<TasbihBloc, TasbihState>(
      builder: (context, state) {
        final isActive = state.presetIndex == presetIndex;
        final count = state.counts[presetIndex];
        final isCompleted = count >= preset.target;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TasbihPageIndicator(
              total: kTasbihPresets.length,
              current: state.presetIndex,
            ),
            const Spacer(flex: 2),
            _PhraseSection(presetKey: preset.key),
            const Spacer(),
            TasbihCounterDisplay(
              count: count,
              target: preset.target,
              isCompleted: isCompleted,
              onTap: isActive ? () => _onTap(context, state) : null,
            ),
            const Spacer(),
            _BottomHint(isCompleted: isCompleted, l: l),
            const Spacer(flex: 2),
          ],
        );
      },
    );
  }

  void _onTap(BuildContext context, TasbihState state) {
    final isLastTap = state.count + 1 >= state.target;
    HapticFeedback.selectionClick();
    if (isLastTap) HapticFeedback.mediumImpact();
    context.read<TasbihBloc>().add(const TasbihTapped());
  }
}

class _PhraseSection extends StatelessWidget {
  final String presetKey;

  const _PhraseSection({required this.presetKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            arabicTasbihPhrase(presetKey),
            // titleMd already resolves the active font via Theme; the explicit
            // override here forced 'Cairo' regardless of the user's choice.
            style: MobileTextStyles.titleMd(context).copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            englishTasbihPhrase(presetKey),
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: MobileColors.onSurfaceFaint(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BottomHint extends StatelessWidget {
  final bool isCompleted;
  final AppLocalizations l;

  const _BottomHint({required this.isCompleted, required this.l});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isCompleted
          ? Text(
              l.tasbihCompletedMessage,
              key: const ValueKey('done'),
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : Text(
              l.tasbihSwipeHint,
              key: const ValueKey('hint'),
              style: MobileTextStyles.labelSm(context).copyWith(
                color: MobileColors.onSurfaceFaint(context),
              ),
            ),
    );
  }
}
