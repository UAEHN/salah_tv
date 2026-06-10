import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/hero_card_logic.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'hero_card_view.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Only the iqama-countdown flag decides the hero-card face now (next-prayer
    // vs iqama). Selecting just this bool keeps the card off the 1 Hz rebuild
    // path; child widgets handle their own per-second countdown updates.
    final isIqamaCountdown = context.select<PrayerBloc, bool>(
      (b) => b.state.isIqamaCountdown,
    );
    final themeKey = context.select<SettingsProvider, String>(
      (p) => p.settings.themeColorKey,
    );
    final palette = getThemePalette(themeKey);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    const logic = HeroCardLogic();
    final model = logic.mapFields(isIqamaCountdown: isIqamaCountdown);

    return HeroCardView(
      model: model,
      palette: palette,
      screenW: screenW,
      screenH: screenH,
    );
  }
}
