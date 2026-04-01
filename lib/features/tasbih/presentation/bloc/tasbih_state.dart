import 'package:flutter/foundation.dart';
import '../../domain/entities/tasbih_preset.dart';

@immutable
class TasbihState {
  final int count;
  final int presetIndex;
  final bool isCompleted;

  const TasbihState({
    required this.count,
    required this.presetIndex,
    this.isCompleted = false,
  });

  const TasbihState.initial()
      : count = 0,
        presetIndex = 0,
        isCompleted = false;

  TasbihPreset get preset => kTasbihPresets[presetIndex];
  int get target => preset.target;

  TasbihState copyWith({int? count, int? presetIndex, bool? isCompleted}) {
    return TasbihState(
      count: count ?? this.count,
      presetIndex: presetIndex ?? this.presetIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
