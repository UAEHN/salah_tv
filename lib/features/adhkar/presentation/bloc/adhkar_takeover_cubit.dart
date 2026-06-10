import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/text_dhikr.dart';
import '../../domain/i_adhkar_text_repository.dart';
import 'adhkar_takeover_state.dart';

/// Rotates a text-adhkar category on a fixed interval while a full-screen
/// adhkar takeover is on display. Display-only: it owns no audio and no cycle
/// state — the prayer engine decides when the screen appears and disappears;
/// this cubit only advances the visible dhikr.
class AdhkarTakeoverCubit extends Cubit<AdhkarTakeoverState> {
  final IAdhkarTextRepository _repository;
  final String _categoryId;
  Timer? _timer; // disposed in close()

  AdhkarTakeoverCubit(this._repository, this._categoryId)
    : super(AdhkarTakeoverState.empty());

  void start() {
    final list = _repository.getByCategory(_categoryId);
    if (list.isEmpty) {
      emit(AdhkarTakeoverState.empty());
      return;
    }
    emit(AdhkarTakeoverState(adhkar: List.unmodifiable(list), index: 0));
    _scheduleNext();
  }

  void next() {
    final s = state;
    if (s.isEmpty) return;
    // Wraps with `%`, so the list keeps looping until the engine tears the
    // takeover down at the end of its display window.
    emit(s.copyWith(index: (s.index + 1) % s.total));
    _scheduleNext();
  }

  /// Schedules the next flip after a dwell sized to the current dhikr's length,
  /// so short adhkar (e.g. «أستغفر الله») pass quickly while long ones (e.g.
  /// آية الكرسي) stay long enough to read.
  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(_dwellFor(state.current), () {
      if (!isClosed) next();
    });
  }

  Duration _dwellFor(TextDhikr dhikr) {
    final ms = (3500 + dhikr.text.length * 55).clamp(5000, 18000);
    return Duration(milliseconds: ms);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
