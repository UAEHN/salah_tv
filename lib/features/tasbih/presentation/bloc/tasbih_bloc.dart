import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../analytics/domain/i_analytics_service.dart';
import '../../domain/entities/tasbih_preset.dart';
import '../../domain/i_tasbih_repository.dart';
import 'tasbih_event.dart';
import 'tasbih_state.dart';

class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final ITasbihRepository _repo;
  final IAnalyticsService? _analytics;

  TasbihBloc(this._repo, {IAnalyticsService? analytics})
      : _analytics = analytics,
        super(const TasbihState.initial()) {
    on<TasbihStarted>(_onStarted);
    on<TasbihTapped>(_onTapped);
    on<TasbihReset>(_onReset);
    on<TasbihPresetChanged>(_onPresetChanged);
  }

  Future<void> _onStarted(
    TasbihStarted event,
    Emitter<TasbihState> emit,
  ) async {
    final count = await _repo.loadCount();
    final rawIndex = await _repo.loadPresetIndex();
    final presetIndex = rawIndex.clamp(0, kTasbihPresets.length - 1);
    emit(state.copyWith(
      count: count,
      presetIndex: presetIndex,
      isCompleted: count >= kTasbihPresets[presetIndex].target,
    ));
  }

  Future<void> _onTapped(
    TasbihTapped event,
    Emitter<TasbihState> emit,
  ) async {
    if (state.isCompleted) return;
    final newCount = state.count + 1;
    final isCompleted = newCount >= state.target;
    emit(state.copyWith(count: newCount, isCompleted: isCompleted));
    if (isCompleted) {
      final preset = kTasbihPresets[state.presetIndex];
      _analytics?.logTasbihCompleted(preset.key, state.target);
    }
    await _repo.saveCount(newCount);
  }

  Future<void> _onReset(
    TasbihReset event,
    Emitter<TasbihState> emit,
  ) async {
    emit(state.copyWith(count: 0, isCompleted: false));
    await _repo.saveCount(0);
  }

  Future<void> _onPresetChanged(
    TasbihPresetChanged event,
    Emitter<TasbihState> emit,
  ) async {
    emit(state.copyWith(
      presetIndex: event.presetIndex,
      count: 0,
      isCompleted: false,
    ));
    await _repo.savePresetIndex(event.presetIndex);
    await _repo.saveCount(0);
  }
}
