import '../../../../core/ticker_content.dart';

/// Immutable snapshot for the ambient screensaver: the slide rotation and the
/// index of the slide currently on screen.
class ScreensaverState {
  final List<TickerItem> slides;
  final int index;

  const ScreensaverState({required this.slides, required this.index});

  factory ScreensaverState.empty() =>
      const ScreensaverState(slides: [], index: 0);

  bool get isEmpty => slides.isEmpty;
  int get total => slides.length;
  TickerItem get current => slides[index];

  ScreensaverState copyWith({int? index}) =>
      ScreensaverState(slides: slides, index: index ?? this.index);
}
