import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/domain/i_analytics_service.dart';
import '../../domain/entities/tasbih_preset.dart';
import 'tasbih_event.dart';
import 'tasbih_state.dart';

class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final IAnalyticsService? _analytics;

  TasbihBloc({IAnalyticsService? analytics})
    : _analytics = analytics,
      super(const TasbihState()) {
    on<TasbihTapped>(_onTapped);
    on<TasbihReset>(_onReset);
    on<TasbihPresetChanged>(_onPresetChanged);
  }

  void _onTapped(TasbihTapped event, Emitter<TasbihState> emit) {
    if (state.isCompleted) return;
    final newCount = state.count + 1;
    final next = state.withCount(state.presetIndex, newCount);
    emit(next);
    if (next.isCompleted) {
      final preset = kTasbihPresets[state.presetIndex];
      _analytics?.logTasbihCompleted(preset.key, state.target);
    }
  }

  void _onReset(TasbihReset event, Emitter<TasbihState> emit) {
    emit(state.withCount(state.presetIndex, 0));
  }

  void _onPresetChanged(TasbihPresetChanged event, Emitter<TasbihState> emit) {
    emit(state.copyWith(presetIndex: event.presetIndex));
  }
}
