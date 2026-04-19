/// Confidence level of the compass reading based on magnetometer variance.
/// [low]    → high interference nearby; calibration recommended.
/// [medium] → moderate stability; usable but not ideal.
/// [high]   → stable readings; accurate direction.
enum QiblaAccuracy { low, medium, high }
