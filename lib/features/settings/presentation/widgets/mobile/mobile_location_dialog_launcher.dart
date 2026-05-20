import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../../../features/prayer/domain/usecases/download_city_use_case.dart';
import '../../../../../injection.dart';
import '../../bloc/location_choice.dart';
import '../../bloc/location_selection_cubit.dart';
import '../../settings_provider.dart';
import 'mobile_location_dialog.dart';

/// Opens the mobile location bottom sheet wired to a [LocationSelectionCubit]
/// so DB-city saves go through download → cache → settings, and failures keep
/// the sheet open with a SnackBar instead of leaving stale times on screen.
Future<void> showMobileLocationDialog(BuildContext context) {
  final settingsProvider = context.read<SettingsProvider>();
  final settings = settingsProvider.settings;
  final cubit = LocationSelectionCubit(
    settingsProvider,
    getIt<DownloadCityUseCase>(),
    getIt<CompositePrayerRepository>(),
  );
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: MobileLocationDialog(
        currentCountry: settings.selectedCountry,
        currentCity: settings.selectedCity,
        onSave: (c, city) => _runSave(
          context,
          cubit,
          LocationChoice.database(countryKey: c, cityName: city),
        ),
        onSaveWorld: (c, city, lat, lng, method,
                {String? timeZoneId, double? utcOffsetHours}) =>
            _runSave(
          context,
          cubit,
          LocationChoice.worldFromValues(
            countryKey: c,
            cityName: city,
            latitude: lat,
            longitude: lng,
            calculationMethod: method,
            timeZoneId: timeZoneId,
            utcOffsetHours: utcOffsetHours,
          ),
        ),
      ),
    ),
  ).whenComplete(cubit.close);
}

Future<bool> _runSave(
  BuildContext hostContext,
  LocationSelectionCubit cubit,
  LocationChoice choice,
) async {
  await cubit.save(choice);
  final ok = cubit.state.status == LocationSelectionStatus.saved;
  if (!ok && hostContext.mounted) {
    ScaffoldMessenger.of(hostContext).showSnackBar(
      SnackBar(
        content: Text(
          cubit.state.downloadError ?? 'تعذّر تحميل بيانات المدينة',
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
  return ok;
}
