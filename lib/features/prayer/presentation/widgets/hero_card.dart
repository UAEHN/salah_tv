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
    final prayerState = context.watch<PrayerBloc>().state;
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final adhkarRepo = context.read<IAdhkarStateRepository>();
    final logic = HeroCardLogic(adhkarRepo);
    final model = logic.mapState(prayer: prayerState, settings: settings);

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
