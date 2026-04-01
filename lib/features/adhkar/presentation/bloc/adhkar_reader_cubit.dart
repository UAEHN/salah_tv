import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/adhkar_category.dart';
import '../../domain/i_adhkar_text_repository.dart';
import 'adhkar_reader_state.dart';

/// Manages navigation and counting for the mobile adhkar reader.
class AdhkarReaderCubit extends Cubit<AdhkarReaderState> {
  final IAdhkarTextRepository _repository;
  Timer? _autoAdvanceTimer;

  AdhkarReaderCubit(this._repository)
      : super(const AdhkarReaderInitial());

  void loadCategories() {
    final categories = _repository.getCategories();
    emit(AdhkarReaderCategories(categories));
  }

  void openCategory(AdhkarCategory category) {
    final adhkar = _repository.getByCategory(category.id);
    if (adhkar.isEmpty) return;

    final counts = Map<int, int>.unmodifiable({
      for (var i = 0; i < adhkar.length; i++) i: adhkar[i].count,
    });

    emit(AdhkarReaderReading(
      category: category,
      adhkar: adhkar,
      currentIndex: 0,
      remainingCounts: counts,
    ));
  }

  void decrementCount() {
    final s = state;
    if (s is! AdhkarReaderReading) return;
    if (s.isCurrentCompleted) return;

    final updated = Map<int, int>.from(s.remainingCounts);
    updated[s.currentIndex] = s.currentRemaining - 1;
    emit(s.copyWith(remainingCounts: updated));

    // Auto-advance when all repetitions done
    if (updated[s.currentIndex]! <= 0) {
      _autoAdvanceTimer?.cancel();
      _autoAdvanceTimer = Timer(const Duration(milliseconds: 400), () {
        if (!isClosed && state is AdhkarReaderReading) next();
      });
    }
  }

  void next() {
    final s = state;
    if (s is! AdhkarReaderReading) return;
    if (s.isLast) {
      emit(AdhkarReaderCompleted(s.category));
    } else {
      emit(s.copyWith(currentIndex: s.currentIndex + 1));
    }
  }

  void previous() {
    final s = state;
    if (s is! AdhkarReaderReading || s.isFirst) return;
    emit(s.copyWith(currentIndex: s.currentIndex - 1));
  }

  void backToCategories() => loadCategories();

  @override
  Future<void> close() {
    _autoAdvanceTimer?.cancel();
    return super.close();
  }
}
