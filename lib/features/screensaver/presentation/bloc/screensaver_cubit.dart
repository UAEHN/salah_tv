import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/i_screensaver_repository.dart';
import 'screensaver_state.dart';

/// Advances the ambient screensaver rotation on a calm, fixed cadence. Slow on
/// purpose — the screensaver is meant to be glanced at, not read against a
/// clock. Visual motion (background + drift) lives in the widgets; this cubit
/// only decides which slide shows.
class ScreensaverCubit extends Cubit<ScreensaverState> {
  final IScreensaverRepository _repository;
  Timer? _timer; // disposed in close()

  static const Duration _interval = Duration(seconds: 14);

  ScreensaverCubit(this._repository) : super(ScreensaverState.empty());

  void start() {
    // Shuffled per session so the long rotation (names + verses + adhkar)
    // feels varied instead of marching through all 99 names in order.
    final slides = List.of(_repository.getSlides())..shuffle();
    if (slides.isEmpty) {
      emit(ScreensaverState.empty());
      return;
    }
    emit(ScreensaverState(slides: List.unmodifiable(slides), index: 0));
    _restartTimer();
  }

  void next() {
    final s = state;
    if (s.isEmpty) return;
    emit(s.copyWith(index: (s.index + 1) % s.total));
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!isClosed) next();
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
