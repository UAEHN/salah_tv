import 'package:flutter/foundation.dart';
import '../../domain/entities/tasbih_preset.dart';

@immutable
class TasbihState {
  final int presetIndex;
  final List<int> counts;

  const TasbihState({
    this.presetIndex = 0,
    this.counts = const [0, 0, 0, 0],
  });

  int get count => counts[presetIndex];
  TasbihPreset get preset => kTasbihPresets[presetIndex];
  int get target => preset.target;
  bool get isCompleted => count >= target;

  bool get isAllCompleted {
    for (int i = 0; i < kTasbihPresets.length; i++) {
      if (counts[i] < kTasbihPresets[i].target) return false;
    }
    return true;
  }

  TasbihState copyWith({int? presetIndex, List<int>? counts}) {
    return TasbihState(
      presetIndex: presetIndex ?? this.presetIndex,
      counts: counts ?? this.counts,
    );
  }

  /// Returns a copy with [value] at [index] in [counts].
  TasbihState withCount(int index, int value) {
    final updated = List<int>.of(counts);
    updated[index] = value;
    return copyWith(counts: updated);
  }
}
