import 'package:flutter/material.dart';

PageRoute<void> buildAppRoute({
  required RouteSettings settings,
  required Widget page,
  bool isInstant = false,
}) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: isInstant
        ? Duration.zero
        : const Duration(milliseconds: 220),
    reverseTransitionDuration: isInstant
        ? Duration.zero
        : const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      if (isInstant) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
