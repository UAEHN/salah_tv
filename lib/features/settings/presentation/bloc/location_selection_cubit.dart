import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../../features/prayer/domain/cancellation_token.dart';
import '../../../../features/prayer/domain/usecases/i_download_city_use_case.dart';
import '../../../../core/error/failures.dart';
import '../settings_provider.dart';
import 'location_choice.dart';

enum LocationSelectionStatus { idle, saving, saved, failed }

enum CityDownloadStatus { idle, downloading, ready, failed }

class LocationSelectionState {
  final LocationSelectionStatus status;
  final CityDownloadStatus downloadStatus;
  final String? downloadError;

  const LocationSelectionState({
    this.status = LocationSelectionStatus.idle,
    this.downloadStatus = CityDownloadStatus.idle,
    this.downloadError,
  });

  static const idle = LocationSelectionState();

  LocationSelectionState copyWith({
    LocationSelectionStatus? status,
    CityDownloadStatus? downloadStatus,
    String? downloadError,
  }) {
    return LocationSelectionState(
      status: status ?? this.status,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadError: downloadError,
    );
  }
}

class LocationSelectionCubit extends Cubit<LocationSelectionState> {
  LocationSelectionCubit(
    this._settingsProvider,
    IDownloadCityUseCase downloadCityUseCase,
    this._compositeRepo, {
    this.onCityReady,
  }) : _downloadCityUseCase = downloadCityUseCase,
       super(LocationSelectionState.idle);

  final SettingsProvider _settingsProvider;
  final IDownloadCityUseCase _downloadCityUseCase;
  final CompositePrayerRepository _compositeRepo;

  /// Called after a DB-city download completes and the repo is in downloaded
  /// mode with data ready. Wire this to dispatch [PrayerReloaded] from the
  /// widget layer so the engine picks up the new city's prayer times.
  final VoidCallback? onCityReady;

  CancellationToken? _cancelToken;
  LocationChoice? _lastDbChoice;

  Future<void> save(LocationChoice choice) async {
    _cancelToken?.cancel();
    _cancelToken = null;

    emit(state.copyWith(status: LocationSelectionStatus.saving));
    try {
      if (choice.isDb) {
        await _settingsProvider.updateLocation(
          choice.countryKey,
          choice.cityName,
        );
        emit(state.copyWith(status: LocationSelectionStatus.saved));
        await _downloadCity(choice);
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
        emit(state.copyWith(
          status: LocationSelectionStatus.saved,
          downloadStatus: CityDownloadStatus.idle,
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: LocationSelectionStatus.failed));
    }
  }

  Future<void> retry() async {
    final last = _lastDbChoice;
    if (last == null) return;
    await _downloadCity(last);
  }

  Future<void> _downloadCity(LocationChoice choice) async {
    _lastDbChoice = choice;
    final token = CancellationToken();
    _cancelToken = token;

    emit(state.copyWith(downloadStatus: CityDownloadStatus.downloading));

    final result = await _downloadCityUseCase(
      countryKey: choice.countryKey,
      cityName: choice.cityName,
      cancelToken: token,
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        if (failure is CancelledFailure) {
          emit(state.copyWith(downloadStatus: CityDownloadStatus.idle));
        } else {
          emit(state.copyWith(
            downloadStatus: CityDownloadStatus.failed,
            downloadError: 'تعذّر تحميل بيانات المدينة',
          ));
        }
      },
      (_) async {
        // loadCity awaits cache rebuild — data is ready before mode switches.
        await _compositeRepo.downloadedRepo.loadCity(
          choice.countryKey,
          choice.cityName,
        );
        _compositeRepo.configureDatabaseMode();
        // Notify engine to call loadToday() so it picks up the new city data
        // immediately rather than waiting for the next null-retry tick.
        onCityReady?.call();
        if (!isClosed) {
          emit(state.copyWith(downloadStatus: CityDownloadStatus.ready));
        }
      },
    );
  }
}
