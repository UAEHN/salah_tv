import 'package:flutter/material.dart';

/// Gold Kaaba marker placed on the rotating compass ring at [qiblaBearing].
class QiblaKaabaMarker extends StatelessWidget {
  const QiblaKaabaMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.7),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.mosque_rounded,
            size: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
