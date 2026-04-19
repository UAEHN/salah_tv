import 'qibla_accuracy.dart';

/// Immutable snapshot of the Qibla compass state.
class QiblaData {
  /// True north bearing (0–360°) from device location to the Kaaba.
  final double qiblaBearing;

  /// Current device compass heading (0–360°), tilt-compensated.
  final double deviceHeading;

  /// Great-circle distance in km from device location to the Kaaba.
  final double distanceKm;

  /// Confidence level derived from magnetometer variance.
  /// [low] when nearby metal/electronics cause interference.
  final QiblaAccuracy accuracy;

  const QiblaData({
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.distanceKm,
    this.accuracy = QiblaAccuracy.low,
  });

  /// Angle (0–360°) to rotate the Qibla pointer on screen so it faces Mecca.
  double get compassAngle => (qiblaBearing - deviceHeading + 360) % 360;

  /// Signed deviation in degrees (shortest path).
  /// Positive = rotate clockwise, negative = rotate counter-clockwise.
  double get deviation {
    final d = (qiblaBearing - deviceHeading + 360) % 360;
    return d > 180 ? d - 360 : d;
  }

  /// True when the device is within ±5° of the Qibla direction.
  bool get isAligned => deviation.abs() < 5.0;
}
