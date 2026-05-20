import '../../domain/entities/theme_palette_info.dart';

/// Sealed-style state hierarchy for the theme picker. Equality lives on the
/// concrete subclasses so `bloc_test` can compare emissions without pulling
/// in `equatable`.
sealed class ThemePickerState {
  const ThemePickerState();
}

class ThemePickerInitial extends ThemePickerState {
  const ThemePickerInitial();

  @override
  bool operator ==(Object other) => other is ThemePickerInitial;

  @override
  int get hashCode => 0;
}

class ThemePickerLoading extends ThemePickerState {
  const ThemePickerLoading();

  @override
  bool operator ==(Object other) => other is ThemePickerLoading;

  @override
  int get hashCode => 1;
}

class ThemePickerLoaded extends ThemePickerState {
  final List<ThemePaletteInfo> palettes;
  final String selectedId;

  /// True while a persistence call is in-flight after the user picked
  /// a palette. UI uses this to lock interactions briefly.
  final bool isApplying;

  const ThemePickerLoaded({
    required this.palettes,
    required this.selectedId,
    this.isApplying = false,
  });

  ThemePickerLoaded copyWith({
    List<ThemePaletteInfo>? palettes,
    String? selectedId,
    bool? isApplying,
  }) {
    return ThemePickerLoaded(
      palettes: palettes ?? this.palettes,
      selectedId: selectedId ?? this.selectedId,
      isApplying: isApplying ?? this.isApplying,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePickerLoaded &&
          _listEquals(other.palettes, palettes) &&
          other.selectedId == selectedId &&
          other.isApplying == isApplying;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(palettes), selectedId, isApplying);
}

class ThemePickerError extends ThemePickerState {
  final String messageKey;

  const ThemePickerError(this.messageKey);

  @override
  bool operator ==(Object other) =>
      other is ThemePickerError && other.messageKey == messageKey;

  @override
  int get hashCode => messageKey.hashCode;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
