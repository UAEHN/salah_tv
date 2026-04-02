import 'package:flutter/material.dart';

/// Wraps a list with per-item staggered fade+slide entrance animations.
/// Items stagger at 40ms intervals, capped at 8 items to avoid excessively
/// long entrances on large lists.
class OnboardingStaggeredList extends StatelessWidget {
  final Animation<double> entranceAnimation;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? scrollController;

  const OnboardingStaggeredList({
    super.key,
    required this.entranceAnimation,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final staggerIndex = index.clamp(0, 7);
        final start = staggerIndex * 0.04;
        final end = (start + 0.4).clamp(0.0, 1.0);
        final itemAnim = CurvedAnimation(
          parent: entranceAnimation,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: itemAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(itemAnim),
            child: itemBuilder(context, index),
          ),
        );
      },
    );
  }
}
