import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/domain/i_settings_repository.dart';
import 'app_tour_state.dart';

export 'app_tour_state.dart';

class AppTourCubit extends Cubit<AppTourState> {
  final ISettingsRepository _settingsRepo;

  AppTourCubit(this._settingsRepo) : super(const AppTourState());

  /// Request the tour (called after onboarding or from settings replay).
  void requestTour() {
    emit(state.copyWith(status: AppTourStatus.requested));
  }

  /// Check persistence and request only if not yet completed.
  Future<void> checkAndRequestTour() async {
    final isCompleted = await _settingsRepo.hasCompletedAppTour();
    if (isClosed) return;
    if (!isCompleted) {
      emit(state.copyWith(status: AppTourStatus.requested));
    }
  }

  /// Mark tour completed (user finished all steps).
  Future<void> completeTour() async {
    await _settingsRepo.markAppTourCompleted();
    if (isClosed) return;
    emit(state.copyWith(status: AppTourStatus.completed));
  }

  /// Mark tour skipped (user pressed skip).
  Future<void> skipTour() async {
    await _settingsRepo.markAppTourCompleted();
    if (isClosed) return;
    emit(state.copyWith(status: AppTourStatus.completed));
  }
}
