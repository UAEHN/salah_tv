import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/i_qibla_repository.dart';
import 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final IQiblaRepository _repository;
  StreamSubscription? _subscription;
  bool _isStarted = false;

  QiblaCubit(this._repository) : super(QiblaInitial());

  void start() {
    if (_isStarted) {
      resume();
      return;
    }
    _isStarted = true;
    emit(QiblaLoading());
    _subscription = _repository.watchQibla().listen(
      (either) =>
          either.fold(_handleFailure, (data) => emit(QiblaActive(data))),
    );
  }

  /// Stops listening to sensor updates so the OS can power them down.
  /// State is preserved so a subsequent [resume] picks up where this left
  /// off without flashing the loading state.
  void pause() {
    if (!_isStarted) return;
    _subscription?.pause();
    _repository.pauseSensors();
  }

  /// Re-attaches sensor listeners after [pause]. No-op if never started.
  void resume() {
    if (!_isStarted) return;
    _repository.resumeSensors();
    if (_subscription?.isPaused ?? false) _subscription!.resume();
  }

  void _handleFailure(Failure failure) {
    if (failure is LocationPermissionFailure) {
      emit(QiblaPermissionDenied());
    } else if (failure is LocationServiceDisabledFailure) {
      emit(QiblaLocationDisabled());
    } else {
      emit(QiblaError(failure.message));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _repository.dispose();
    return super.close();
  }
}
