import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/i_qibla_repository.dart';
import 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final IQiblaRepository _repository;
  StreamSubscription? _subscription;

  QiblaCubit(this._repository) : super(QiblaInitial());

  void start() {
    emit(QiblaLoading());
    _subscription = _repository.watchQibla().listen(
      (either) => either.fold(
        _handleFailure,
        (data) => emit(QiblaActive(data)),
      ),
    );
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
