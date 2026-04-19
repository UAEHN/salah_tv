import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_state.dart';
import '../bloc/hero_card_logic.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../adhkar/domain/i_adhkar_state_repository.dart';
import 'hero_card_view.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Select only fields that decide which HeroCard mode to display.
    // countdown is bucketed to the evening-adhkar boundary (>5 min) so this
    // widget does not rebuild every tick; child widgets handle their own
    // per-second countdown updates through narrow selectors.
    final keys = context.select<PrayerBloc, (bool, String, bool, bool)>((b) {
      final s = b.state;
      return (
        s.isIqamaCountdown,
        s.nextPrayerKey,
        s.isCycleActive,
        s.countdown.inSeconds > 5 * 60,
      );
    });
    final isIqamaCountdown = keys.$1;
    final nextPrayerKey = keys.$2;
    final isCycleActive = keys.$3;
    final countdownAbove5Min = keys.$4;

    final themeKey = context.select<SettingsProvider, String>(
      (p) => p.settings.themeColorKey,
    );
    final isAdhkarEnabled = context.select<SettingsProvider, bool>(
      (p) => p.settings.isAdhkarEnabled,
    );
    final palette = getThemePalette(themeKey);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final adhkarRepo = context.read<IAdhkarStateRepository>();
    final logic = HeroCardLogic(adhkarRepo);
    final model = logic.mapFields(
      isIqamaCountdown: isIqamaCountdown,
      nextPrayerKey: nextPrayerKey,
      isCycleActive: isCycleActive,
      countdownSeconds: countdownAbove5Min ? 6 * 60 : 0,
      isAdhkarEnabled: isAdhkarEnabled,
    );

    return BlocListener<PrayerBloc, PrayerState>(
      listenWhen: logic.shouldStartMorningSession,
      listener: (context, state) {
        logic.startMorningSessionIfNeeded();
      },
      child: HeroCardView(
        model: model,
        palette: palette,
        screenW: screenW,
        screenH: screenH,
      ),
    );
  }
}
