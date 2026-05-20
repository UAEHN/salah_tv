import 'package:flutter/material.dart';

/// Wraps a child with a fade-in + small upward translation that triggers on
/// first build. The screen mounts a list of tiles with staggered [delay]s so
/// the bento appears as a sequence — premium feel without leaning on heavy
/// libraries.
class TodayStaggeredEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const TodayStaggeredEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
  });

  @override
  State<TodayStaggeredEntry> createState() => _TodayStaggeredEntryState();
}

class _TodayStaggeredEntryState extends State<TodayStaggeredEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
