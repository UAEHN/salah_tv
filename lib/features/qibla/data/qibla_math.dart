import 'dart:math' as math;

// Kaaba coordinates (Mecca, Saudi Arabia)
const _kKaabaLat = 21.4225;
const _kKaabaLng = 39.8262;

/// True-north bearing (0–360°) from [lat]/[lng] to the Kaaba.
double calculateQiblaBearing(double lat, double lng) {
  final kaabaLatR = _kKaabaLat * math.pi / 180;
  final kaabaLngR = _kKaabaLng * math.pi / 180;
  final latR = lat * math.pi / 180;
  final dLng = kaabaLngR - lng * math.pi / 180;
  final y = math.sin(dLng) * math.cos(kaabaLatR);
  final x = math.cos(latR) * math.sin(kaabaLatR) -
      math.sin(latR) * math.cos(kaabaLatR) * math.cos(dLng);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Great-circle distance in km from [lat]/[lng] to the Kaaba (Haversine).
double calculateDistanceKm(double lat, double lng) {
  const r = 6371.0;
  final lat1 = lat * math.pi / 180;
  final lng1 = lng * math.pi / 180;
  final kaabaLatR = _kKaabaLat * math.pi / 180;
  final kaabaLngR = _kKaabaLng * math.pi / 180;
  final dLat = kaabaLatR - lat1;
  final dLng = kaabaLngR - lng1;
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(kaabaLatR) * math.pow(math.sin(dLng / 2), 2);
  return r * 2 * math.asin(math.sqrt(a.toDouble()));
}

/// Tilt-compensated compass heading (0–360°) using raw accelerometer and
/// magnetometer components.  Handles phone tilt to reduce heading drift.
double computeHeading({
  required double ax,
  required double ay,
  required double az,
  required double mx,
  required double my,
  required double mz,
}) {
  final norm = math.sqrt(ax * ax + ay * ay + az * az);
  if (norm < 0.001) return 0;
  final pitch = math.asin((-ax / norm).clamp(-1.0, 1.0));
  final roll = math.asin((ay / norm).clamp(-1.0, 1.0));
  final cosPitch = math.cos(pitch);
  final sinPitch = math.sin(pitch);
  final cosRoll = math.cos(roll);
  final sinRoll = math.sin(roll);
  final cx = mx * cosPitch + mz * sinPitch;
  final cy = mx * sinRoll * sinPitch + my * cosRoll - mz * sinRoll * cosPitch;
  // Portrait mode: atan2(-Xh, Yh). Using landscape atan2(-Yh, Xh) gives
  // a 90° error (reports West when pointing North).
  return (math.atan2(-cx, cy) * 180 / math.pi + 360) % 360;
}

/// Low-pass filter for angles — takes shortest arc to avoid 359°→1° jumps.
double angleLowPass(double current, double target, {double alpha = 0.15}) {
  double diff = target - current;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return current + alpha * diff;
}
