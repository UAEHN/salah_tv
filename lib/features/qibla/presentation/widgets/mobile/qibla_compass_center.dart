import 'package:flutter/material.dart';

class QiblaCompassCenter extends StatelessWidget {
  final double angle;

  const QiblaCompassCenter({
    super.key,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${angle.toInt()}°',
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          Icons.mosque_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: 20,
        ),
      ],
    );
  }
}
