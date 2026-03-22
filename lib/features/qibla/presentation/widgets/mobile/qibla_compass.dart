import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import 'qibla_compass_center.dart';
import 'qibla_compass_pointer.dart';
import 'qibla_direction_label.dart';
import 'qibla_kaaba_marker.dart';

/// North-up compass: ring rotates with device so N tracks geographic North.
/// Blue pointer = phone direction (fixed up). Gold marker = Mecca position.
/// Rotate body until gold marker reaches blue pointer → facing Mecca.
class QiblaCompass extends StatefulWidget {
  final double qiblaBearing;  // absolute GPS bearing to Mecca (0–360°)
  final double deviceHeading; // current compass heading of device (0–360°)

  const QiblaCompass({
    super.key,
    required this.qiblaBearing,
    required this.deviceHeading,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _smoothHeading = 0;
  double _targetHeading = 0;

  @override
  void initState() {
    super.initState();
    _smoothHeading = widget.deviceHeading;
    _targetHeading = widget.deviceHeading;
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )
      ..addListener(_onFrame)
      ..repeat();
  }

  @override
  void didUpdateWidget(QiblaCompass old) {
    super.didUpdateWidget(old);
    _targetHeading = widget.deviceHeading;
  }

  void _onFrame() {
    double diff = _targetHeading - _smoothHeading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    final next = _smoothHeading + 0.15 * diff;
    if ((next - _smoothHeading).abs() > 0.01) {
      setState(() => _smoothHeading = next);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compassAngle = (widget.qiblaBearing - _smoothHeading + 360) % 360;

    return RepaintBoundary(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MobileColors.cardColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 2,
                ),
              ),
            ),
            // Geographic ring — rotates so N tracks real North
            Transform.rotate(
              angle: -_smoothHeading * (math.pi / 180),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const QiblaDirectionLabel(label: 'N', alignment: Alignment.topCenter),
                  const QiblaDirectionLabel(label: 'E', alignment: Alignment.centerRight),
                  const QiblaDirectionLabel(label: 'S', alignment: Alignment.bottomCenter),
                  const QiblaDirectionLabel(label: 'W', alignment: Alignment.centerLeft),
                  Transform.rotate(
                    angle: widget.qiblaBearing * (math.pi / 180),
                    child: const QiblaKaabaMarker(),
                  ),
                ],
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.03),
                  width: 1,
                ),
              ),
            ),
            // Phone direction indicator — fixed pointing up, no rotation
            const QiblaCompassPointer(),
            QiblaCompassCenter(angle: compassAngle),
          ],
        ),
      ),
    );
  }
}
