import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/settings/presentation/bloc/location_selection_cubit.dart';
import '../../../../features/settings/presentation/settings_provider.dart';
import '../../../../features/settings/presentation/widgets/mobile/mobile_location_dialog.dart';
import '../widgets/mobile/mobile_home_background.dart';
import '../widgets/mobile/mobile_home_content.dart';

/// Mobile home screen — gradient background with animated soft orbs for depth.
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
    return Stack(
      children: [
        const MobileHomeBackground(),
        MobileHomeContent(
          city: city,
          country: country,
          is24HourFormat: is24HourFormat,
          onLocationTap: () => _showLocationDialog(context),
        ),
      ],
    );
  }

  void _showLocationDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>().settings;
    final locationCubit = LocationSelectionCubit(
      context.read<SettingsProvider>(),
    );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: locationCubit,
        child: MobileLocationDialog(
          currentCountry: settings.selectedCountry,
          currentCity: settings.selectedCity,
          onSave: (c, city) => locationCubit.saveDatabaseLocation(c, city),
          onSaveWorld: (c, city, lat, lng, method, {double? utcOffsetHours}) =>
              locationCubit.saveWorldLocation(
                c,
                city,
                lat,
                lng,
                method,
                utcOffsetHours: utcOffsetHours,
              ),
        ),
      ),
    ).whenComplete(locationCubit.close);
  }
}
