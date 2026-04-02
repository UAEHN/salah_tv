import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings_provider.dart';

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

  Future<void> saveDatabaseLocation(String country, String city) async {
    emit(const LocationSelectionState(LocationSelectionStatus.saving));
    try {
      await _settingsProvider.updateLocation(country, city);
      emit(const LocationSelectionState(LocationSelectionStatus.saved));
    } catch (_) {
      emit(const LocationSelectionState(LocationSelectionStatus.failed));
    }
  }

  Future<void> saveWorldLocation(
    String country,
    String city,
    double lat,
    double lng,
    String method, {
    double? utcOffsetHours,
  }) async {
    emit(const LocationSelectionState(LocationSelectionStatus.saving));
    try {
      await _settingsProvider.updateWorldLocation(
        country,
        city,
        lat,
        lng,
        method,
        utcOffsetHours: utcOffsetHours,
      );
      emit(const LocationSelectionState(LocationSelectionStatus.saved));
    } catch (_) {
      emit(const LocationSelectionState(LocationSelectionStatus.failed));
    }
  }
}
