import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../../features/prayer/domain/usecases/download_city_use_case.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../../../../features/settings/presentation/bloc/location_choice.dart';
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
    final mq = MediaQuery.of(context);
    final fontFamily = context.select<SettingsProvider, String>(
      (p) => p.settings.fontFamily,
    );
    final isRubik = fontFamily == 'Rubik';
    final scaledMq = isRubik
        ? mq
        : mq.copyWith(
            textScaler: mq.textScaler
                .clamp(minScaleFactor: 1.15, maxScaleFactor: 1.3),
          );
    return MediaQuery(
      data: scaledMq,
      child: Stack(
        children: [
          const MobileHomeBackground(),
          MobileHomeContent(
            city: city,
            country: country,
            is24HourFormat: is24HourFormat,
            onLocationTap: () => _showLocationDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>().settings;
    final locationCubit = LocationSelectionCubit(
      context.read<SettingsProvider>(),
      getIt<DownloadCityUseCase>(),
      getIt<CompositePrayerRepository>(),
    );
    final bloc = context.read<PrayerBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: locationCubit,
        child: MobileLocationDialog(
          currentCountry: settings.selectedCountry,
          currentCity: settings.selectedCity,
          onSave: (c, city) async {
            await locationCubit.save(
              LocationChoice.database(countryKey: c, cityName: city),
            );
            bloc.add(const PrayerReloaded());
            return true;
          },
          onSaveWorld: (
            c,
            city,
            lat,
            lng,
            method, {
            String? timeZoneId,
            double? utcOffsetHours,
          }) async {
            await locationCubit.save(
              LocationChoice.worldFromValues(
                countryKey: c,
                cityName: city,
                latitude: lat,
                longitude: lng,
                calculationMethod: method,
                timeZoneId: timeZoneId,
                utcOffsetHours: utcOffsetHours,
              ),
            );
            bloc.add(const PrayerReloaded());
            return true;
          },
        ),
      ),
    ).whenComplete(locationCubit.close);
  }
}
