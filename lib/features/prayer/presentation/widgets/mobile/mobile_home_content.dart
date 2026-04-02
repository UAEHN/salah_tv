import 'package:flutter/material.dart';

import 'mobile_hero_card.dart';
import 'mobile_prayer_list.dart';
import 'mobile_top_bar.dart';

class MobileHomeContent extends StatelessWidget {
  final String city;
  final String country;
  final bool is24HourFormat;
  final VoidCallback onLocationTap;

  const MobileHomeContent({
    super.key,
    required this.city,
    required this.country,
    required this.is24HourFormat,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          MobileTopBar(
            city: city,
            country: country,
            onLocationTap: onLocationTap,
          ),
          const SizedBox(height: 8),
          const MobileHeroCard(),
          const SizedBox(height: 20),
          Expanded(child: MobilePrayerList(is24HourFormat: is24HourFormat)),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
        ],
      ),
    );
  }
}
