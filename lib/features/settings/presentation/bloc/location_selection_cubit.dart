import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings_provider.dart';
import 'location_choice.dart';

enum LocationSelectionStatus { idle, saving, saved, failed }

class LocationSelectionState {
  final LocationSelectionStatus status;

  const LocationSelectionState(this.status);

  static const idle = LocationSelectionState(LocationSelectionStatus.idle);
}

class LocationSelectionCubit extends Cubit<LocationSelectionState> {
  final SettingsProvider _settingsProvider;

  LocationSelectionCubit(this._settingsProvider)
    : super(LocationSelectionState.idle);

  Future<void> save(LocationChoice choice) async {
    emit(const LocationSelectionState(LocationSelectionStatus.saving));
    try {
      if (choice.isDb) {
        await _settingsProvider.updateLocation(
          choice.countryKey,
          choice.cityName,
        );
      } else {
        await _settingsProvider.updateWorldLocation(
          choice.countryKey,
          choice.cityName,
          choice.latitude!,
          choice.longitude!,
          choice.calculationMethod!,
          timeZoneId: choice.timeZoneId,
          utcOffsetHours: choice.utcOffsetHours,
        );
      }
      emit(const LocationSelectionState(LocationSelectionStatus.saved));
    } catch (_) {
      emit(const LocationSelectionState(LocationSelectionStatus.failed));
    }
  }
}
