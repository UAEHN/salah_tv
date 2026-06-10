import 'package:flutter/material.dart';

import '../../../domain/entities/online_geocoding_result.dart';
import '../../bloc/location_choice.dart';
import '../../bloc/location_selection_cubit.dart';
import '../../screens/tv_calculation_method_picker_screen.dart';
import '../../screens/tv_prayer_offsets_screen.dart';
import 'tv_calibration_prompt.dart';

/// TV worldwide-pick continuation: method picker → optional calibration
/// prompt → cubit save → optional calibration route. Entered with a
/// result the user already tapped inline in the picker dialog.
class TvOnlineLocationFlow {
  final LocationSelectionCubit selectionCubit;
  final NavigatorState rootNavigator;
  final BuildContext Function() contextGetter;
  final bool Function() isContextMounted;

  const TvOnlineLocationFlow({
    required this.selectionCubit,
    required this.rootNavigator,
    required this.contextGetter,
    required this.isContextMounted,
  });

  Future<void> runFrom(OnlineGeocodingResult picked) async {
    final method = await TvCalculationMethodPickerScreen.push(
      contextGetter(),
      latitude: picked.latitude,
      longitude: picked.longitude,
      cityName: picked.name,
      isoCountryCode: picked.countryCode,
    );
    if (method == null || !isContextMounted()) return;
    // ignore: use_build_context_synchronously
    final wantsCalibration = await TvCalibrationPrompt.show(contextGetter());
    await selectionCubit.save(
      LocationChoice.worldFromValues(
        countryKey: picked.countryCode,
        cityName: picked.name,
        latitude: picked.latitude,
        longitude: picked.longitude,
        calculationMethod: method,
      ),
    );
    if (wantsCalibration) {
      rootNavigator.push(
        MaterialPageRoute(builder: (_) => const TvPrayerOffsetsScreen()),
      );
    }
  }
}
