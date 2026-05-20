import 'package:flutter/material.dart';

/// Background sky panel that drifts upward at a fraction of the scroll
/// offset, giving the bento a parallax depth without obscuring foreground
/// readability. The widget listens to [scrollController] and translates the
/// underlying gradient by `offset * factor` (factor ~0.25).
class TodayParallaxSky extends StatefulWidget {
  final ScrollController scrollController;
  final List<Color> colors;
  final double factor;

  const TodayParallaxSky({
    super.key,
    required this.scrollController,
    required this.colors,
    this.factor = 0.25,
  });

  @override
  State<TodayParallaxSky> createState() => _TodayParallaxSkyState();
}

class _TodayParallaxSkyState extends State<TodayParallaxSky> {
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final next = widget.scrollController.offset * widget.factor;
    if ((next - _offset).abs() < 0.5) return;
    setState(() => _offset = next);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -_offset),
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.colors,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
