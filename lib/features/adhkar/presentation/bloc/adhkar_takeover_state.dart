import '../../domain/entities/text_dhikr.dart';

/// Immutable snapshot for a full-screen adhkar takeover: the playlist for the
/// active category and the index of the dhikr currently on screen.
class AdhkarTakeoverState {
  final List<TextDhikr> adhkar;
  final int index;

  const AdhkarTakeoverState({required this.adhkar, required this.index});

  factory AdhkarTakeoverState.empty() =>
      const AdhkarTakeoverState(adhkar: [], index: 0);

  bool get isEmpty => adhkar.isEmpty;
  int get total => adhkar.length;
  TextDhikr get current => adhkar[index];

  AdhkarTakeoverState copyWith({int? index}) =>
      AdhkarTakeoverState(adhkar: adhkar, index: index ?? this.index);
}
