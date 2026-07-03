import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/khatma_plan.dart';
import '../../domain/khatma_calculator.dart';
import '../../domain/usecases/khatma_usecases.dart';
import 'khatma_state.dart';

/// Owns the single active Khatma (reading plan). Hoisted in `MobileShell` so
/// the Today tile and the Khatma screen share one instance.
///
/// Progress is wird-driven: the user reads today's portion in the constrained
/// reader and confirms with «أتممت الورد», which calls [completeWird]. "Today"
/// comes from the device clock; the day boundary is local midnight (see
/// [KhatmaCalculator]).
class KhatmaCubit extends Cubit<KhatmaState> {
  final GetActiveKhatmaUseCase _get;
  final SaveKhatmaUseCase _save;
  final ClearKhatmaUseCase _clear;

  KhatmaCubit({
    required GetActiveKhatmaUseCase get,
    required SaveKhatmaUseCase save,
    required ClearKhatmaUseCase clear,
  }) : _get = get,
       _save = save,
       _clear = clear,
       super(const KhatmaState());

  Future<void> load() async {
    final k = await _get();
    if (isClosed) return;
    emit(KhatmaState(isLoaded: true, khatma: k));
  }

  Future<void> createByDuration(int days) async {
    final now = DateTime.now();
    final k = KhatmaCalculator.createByDuration(
      startDate: now,
      durationDays: days,
      createdAt: now,
    );
    await _save(k);
    if (isClosed) return;
    emit(KhatmaState(isLoaded: true, khatma: k));
  }

  /// Marks every page in [wird] as read (the user confirmed today's portion),
  /// advancing the plan and flipping it to completed when the range is done.
  Future<void> completeWird(KhatmaWird wird) async {
    final current = state.khatma;
    if (current == null || current.status != KhatmaStatus.active) return;
    final now = DateTime.now();
    var updated = current;
    for (var p = wird.first; p <= wird.last; p++) {
      updated = KhatmaCalculator.recordPage(updated, p, now);
    }
    if (identical(updated, current)) return;
    await _save(updated);
    if (isClosed) return;
    emit(KhatmaState(isLoaded: true, khatma: updated));
  }

  Future<void> clear() async {
    await _clear();
    if (isClosed) return;
    emit(const KhatmaState(isLoaded: true));
  }
}
