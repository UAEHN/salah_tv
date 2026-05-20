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

/// Persists a location choice atomically:
/// 1. download city data → 2. prime repo cache → 3. update settings.
/// Settings are only written after the download succeeds, so the engine never
/// sees a city without prayer-time data.
class LocationSelectionCubit extends Cubit<LocationSelectionState> {
  LocationSelectionCubit(
    this._settingsProvider,
    IDownloadCityUseCase downloadCityUseCase,
    this._compositeRepo,
  )   : _downloadCityUseCase = downloadCityUseCase,
        super(LocationSelectionState.idle);

  final SettingsProvider _settingsProvider;
  final IDownloadCityUseCase _downloadCityUseCase;
  final CompositePrayerRepository _compositeRepo;

  CancellationToken? _cancelToken;
  LocationChoice? _lastDbChoice;

  Future<void> save(LocationChoice choice) async {
    _cancelToken?.cancel();
    _cancelToken = null;

    if (choice.isDb) {
      await _saveDbCity(choice);
    } else {
      await _saveWorldCity(choice);
    }
  }

  Future<void> retry() async {
    final last = _lastDbChoice;
    if (last == null) return;
    await _saveDbCity(last);
  }

  Future<void> _saveDbCity(LocationChoice choice) async {
    _lastDbChoice = choice;
    final token = CancellationToken();
    _cancelToken = token;

    emit(state.copyWith(
      status: LocationSelectionStatus.saving,
      downloadStatus: CityDownloadStatus.downloading,
    ));

    final result = await _downloadCityUseCase(
      countryKey: choice.countryKey,
      cityName: choice.cityName,
      cancelToken: token,
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        if (failure is CancelledFailure) {
          emit(state.copyWith(
            status: LocationSelectionStatus.idle,
            downloadStatus: CityDownloadStatus.idle,
          ));
        } else {
          emit(state.copyWith(
            status: LocationSelectionStatus.failed,
            downloadStatus: CityDownloadStatus.failed,
            downloadError: 'تعذّر تحميل بيانات المدينة',
          ));
        }
      },
      (_) async {
        // Prime the cache BEFORE persisting settings so the bridge-driven
        // engine refresh reads the new city's data immediately.
        await _compositeRepo.downloadedRepo.loadCity(
          choice.countryKey,
          choice.cityName,
        );
        _compositeRepo.configureDatabaseMode();
        await _settingsProvider.updateLocation(
          choice.countryKey,
          choice.cityName,
        );
        if (!isClosed) {
          emit(state.copyWith(
            status: LocationSelectionStatus.saved,
            downloadStatus: CityDownloadStatus.ready,
          ));
        }
      },
    );
  }

  Future<void> _saveWorldCity(LocationChoice choice) async {
    emit(state.copyWith(status: LocationSelectionStatus.saving));
    try {
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
    } catch (_) {
      emit(state.copyWith(status: LocationSelectionStatus.failed));
    }
  }
}
