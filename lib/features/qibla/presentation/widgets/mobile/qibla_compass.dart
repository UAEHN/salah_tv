import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'qibla_compass_center.dart';
import 'qibla_compass_face.dart';
import 'qibla_compass_pointer.dart';
import 'qibla_direction_label.dart';
import 'qibla_kaaba_marker.dart';

/// North-up compass: ring rotates with the device so N tracks geographic
/// North. The pointer at top indicates "where the phone is pointing"; the
/// gold Kaaba marker sits on the ring. Rotate the body until the marker
/// reaches the pointer → facing Mecca.
class QiblaCompass extends StatefulWidget {
  final double qiblaBearing;
  final double deviceHeading;
  final bool isAligned;

  const QiblaCompass({
    super.key,
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.isAligned,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _smoothHeading = 0;
  double _targetHeading = 0;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _smoothHeading = widget.deviceHeading;
    _targetHeading = widget.deviceHeading;
    _wasAligned = widget.isAligned;
    _ticker =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(_onFrame)
          ..repeat();
  }

  @override
  void didUpdateWidget(QiblaCompass old) {
    super.didUpdateWidget(old);
    _targetHeading = widget.deviceHeading;
    if (widget.isAligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
    }
    _wasAligned = widget.isAligned;
  }

  void _onFrame() {
    double diff = _targetHeading - _smoothHeading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    final next = _smoothHeading + 0.08 * diff;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        width: 280,
        height: 280,
        decoration: qiblaFaceDecoration(context, widget.isAligned),
        child: Stack(
          alignment: Alignment.center,
          children: _faceLayers(compassAngle),
        ),
      ),
    );
  }

  List<Widget> _faceLayers(double compassAngle) {
    return [
      const QiblaCompassGuideRing(size: 230, alpha: 0.06),
      const QiblaCompassGuideRing(size: 170, alpha: 0.05),
      Transform.rotate(
        angle: -_smoothHeading * (math.pi / 180),
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final pair in qiblaCardinals)
              QiblaDirectionLabel(label: pair.$1, alignment: pair.$2),
            Transform.rotate(
              angle: widget.qiblaBearing * (math.pi / 180),
              child: AnimatedScale(
                scale: widget.isAligned ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                child: QiblaKaabaMarker(isAligned: widget.isAligned),
              ),
            ),
          ],
        ),
      ),
      QiblaCompassPointer(isAligned: widget.isAligned),
      QiblaCompassCenter(angle: compassAngle, isAligned: widget.isAligned),
    ];
  }
}
