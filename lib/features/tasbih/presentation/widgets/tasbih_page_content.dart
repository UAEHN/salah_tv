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
        final count = isActive ? state.count : 0;
        final isCompleted = isActive && state.isCompleted;

        return LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final arabicSize = (h * 0.065).clamp(24.0, 40.0);
            final engSize = (h * 0.030).clamp(13.0, 18.0);
            final spacing1 = (h * 0.04).clamp(8.0, 36.0);
            final spacing2 = (h * 0.03).clamp(6.0, 24.0);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TasbihPageIndicator(
                  total: kTasbihPresets.length,
                  current: state.presetIndex,
                ),
                SizedBox(height: spacing1),
                Text(
                  arabicTasbihPhrase(preset.key),
                  style: MobileTextStyles.titleMd(context).copyWith(
                    fontSize: arabicSize,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: spacing2 * 0.5),
                Text(
                  englishTasbihPhrase(preset.key),
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: engSize,
                    fontStyle: FontStyle.italic,
                    color: MobileColors.onSurfaceMuted(context),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing2),
                TasbihCounterDisplay(
                  count: count,
                  target: preset.target,
                  isCompleted: isCompleted,
                  onTap: isActive
                      ? () {
                          HapticFeedback.selectionClick();
                          context.read<TasbihBloc>().add(const TasbihTapped());
                        }
                      : null,
                ),
                SizedBox(height: spacing2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isCompleted
                      ? Text(
                          l.tasbihCompletedMessage,
                          key: const ValueKey('done'),
                          style: MobileTextStyles.bodyMd(context).copyWith(
                            color: Colors.green,
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
                ),
              ],
            );
          },
        );
      },
    );
  }
}
