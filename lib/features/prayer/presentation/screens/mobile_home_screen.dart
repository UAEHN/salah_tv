import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../../core/mobile_theme.dart';
import '../widgets/mobile/mobile_top_bar.dart';
import '../widgets/mobile/mobile_hero_card.dart';
import '../widgets/mobile/mobile_prayer_list.dart';
import '../widgets/mobile/mobile_bottom_nav.dart';

/// Mobile home screen — "Desert Oasis" dark design (prayer_times.html).
/// PrayerBloc drives all state; build() is side-effect-free.
class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger rebuild when city changes (city shown in hero section elsewhere).
    context.select((SettingsProvider p) => p.settings.selectedCity);

    return Scaffold(
      backgroundColor: MobileColors.background,
      bottomNavigationBar: const MobileBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const MobileTopBar(),
            const SizedBox(height: 24),
            const MobileHeroCard(),
            const SizedBox(height: 24),
            const Expanded(child: MobilePrayerList()),
          ],
        ),
      ),
    );
  }
}
