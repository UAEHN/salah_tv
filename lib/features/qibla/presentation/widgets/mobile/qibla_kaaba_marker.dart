import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MobileColors.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: MobileColors.primary.withValues(alpha: 0.7),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.mosque_rounded,
            size: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
