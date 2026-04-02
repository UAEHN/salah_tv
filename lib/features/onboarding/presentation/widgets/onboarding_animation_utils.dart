import 'package:flutter/material.dart';

Animation<double> onboardingInterval({
  required Animation<double> parent,
  required double start,
  required double end,
  Curve curve = Curves.easeOut,
}) {
  return CurvedAnimation(
    parent: parent,
    curve: Interval(start, end, curve: curve),
  );
}

Animation<Offset> onboardingSlideIn({
  required Animation<double> parent,
  required double start,
  required double end,
  Offset begin = const Offset(0, 0.2),
  Curve curve = Curves.easeOut,
}) {
  return Tween<Offset>(begin: begin, end: Offset.zero).animate(
    onboardingInterval(parent: parent, start: start, end: end, curve: curve),
  );
}
