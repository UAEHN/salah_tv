import '../../domain/entities/quran_font_info.dart';

sealed class FontPickerState {
  const FontPickerState();
}

class FontPickerInitial extends FontPickerState {
  const FontPickerInitial();

  @override
  bool operator ==(Object other) => other is FontPickerInitial;

  @override
  int get hashCode => 0;
}

class FontPickerLoading extends FontPickerState {
  const FontPickerLoading();

  @override
  bool operator ==(Object other) => other is FontPickerLoading;

  @override
  int get hashCode => 1;
}

class FontPickerLoaded extends FontPickerState {
  final List<QuranFontInfo> fonts;
  final String selectedFamily;
  final bool isApplying;

  const FontPickerLoaded({
    required this.fonts,
    required this.selectedFamily,
    this.isApplying = false,
  });

  FontPickerLoaded copyWith({
    List<QuranFontInfo>? fonts,
    String? selectedFamily,
    bool? isApplying,
  }) {
    return FontPickerLoaded(
      fonts: fonts ?? this.fonts,
      selectedFamily: selectedFamily ?? this.selectedFamily,
      isApplying: isApplying ?? this.isApplying,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontPickerLoaded &&
          _listEquals(other.fonts, fonts) &&
          other.selectedFamily == selectedFamily &&
          other.isApplying == isApplying;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(fonts), selectedFamily, isApplying);
}

class FontPickerError extends FontPickerState {
  final String messageKey;

  const FontPickerError(this.messageKey);

  @override
  bool operator ==(Object other) =>
      other is FontPickerError && other.messageKey == messageKey;

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
