import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculation_method_info.dart';
import '../../domain/i_location_detector.dart';
import '../../domain/i_settings_repository.dart';
import '../../domain/usecases/first_launch_location_usecase.dart';
import '../settings_provider.dart';

enum FirstLaunchLocationStatus { idle, loading, skipped, applied, failed }

class FirstLaunchLocationState {
  final FirstLaunchLocationStatus status;

  const FirstLaunchLocationState(this.status);

  static const idle = FirstLaunchLocationState(FirstLaunchLocationStatus.idle);
}

class FirstLaunchLocationCubit extends Cubit<FirstLaunchLocationState> {
  final SettingsProvider _settingsProvider;
  final FirstLaunchLocationUseCase _useCase;
  bool _hasRun = false;

  FirstLaunchLocationCubit(
    this._settingsProvider,
    ISettingsRepository settingsRepository,
    ILocationDetector locationDetector,
  ) : _useCase = FirstLaunchLocationUseCase(
        settingsRepository,
        locationDetector,
      ),
      super(FirstLaunchLocationState.idle);

  Future<void> runOnce() async {
    if (_hasRun) return;
    _hasRun = true;
    emit(const FirstLaunchLocationState(FirstLaunchLocationStatus.loading));

    try {
      final detected = await _useCase();
      if (detected == null) {
        emit(const FirstLaunchLocationState(FirstLaunchLocationStatus.skipped));
        return;
      }

      if (detected.isInDb) {
        await _settingsProvider.updateLocation(
          detected.dbCountryKey!,
          detected.dbCityKey!,
        );
      } else {
        await _settingsProvider.updateWorldLocation(
          detected.countryName,
          detected.cityName,
          detected.latitude,
          detected.longitude,
          defaultMethodForCountryIso(detected.isoCountryCode),
        );
      }

      emit(const FirstLaunchLocationState(FirstLaunchLocationStatus.applied));
    } catch (_) {
      emit(const FirstLaunchLocationState(FirstLaunchLocationStatus.failed));
    }
  }
}
