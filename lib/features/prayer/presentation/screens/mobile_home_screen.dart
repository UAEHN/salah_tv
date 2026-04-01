import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mobile_theme.dart';
import '../../../../features/settings/presentation/settings_provider.dart';
import '../../../../features/settings/presentation/widgets/mobile/mobile_location_dialog.dart';
import '../widgets/mobile/mobile_top_bar.dart';
import '../widgets/mobile/mobile_hero_card.dart';
import '../widgets/mobile/mobile_prayer_list.dart';

/// Mobile home screen — "Modern Oasis" dark design.
/// PrayerBloc drives all state; build() is side-effect-free.
class MobileHomeScreen extends StatelessWidget {
  final String city;
  final String country;
  final bool is24HourFormat;

  const MobileHomeScreen({
    super.key,
    required this.city,
    required this.country,
    required this.is24HourFormat,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.primaryContainer.withValues(
                alpha: MobileColors.isDark(context) ? 0.08 : 0.12,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: const SizedBox(),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              MobileTopBar(
                city: city,
                country: country,
                onLocationTap: () {
                  final sp = context.read<SettingsProvider>();
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => MobileLocationDialog(
                      currentCountry: sp.settings.selectedCountry,
                      currentCity: sp.settings.selectedCity,
                      onSave: (c, city) => sp.updateLocation(c, city),
                      onSaveWorld: (c, city, lat, lng, method,
                              {double? utcOffsetHours}) =>
                          sp.updateWorldLocation(c, city, lat, lng, method,
                              utcOffsetHours: utcOffsetHours),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const MobileHeroCard(),
              const SizedBox(height: 32),
              Expanded(
                child: MobilePrayerList(is24HourFormat: is24HourFormat),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 80,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
