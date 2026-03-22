import 'package:intl/intl.dart';

String formatPrayerTime(DateTime dt, {required bool use24Hour}) {
  if (use24Hour) return DateFormat('HH:mm').format(dt);
  return DateFormat('hh:mm').format(dt);
}

/// Returns 'ص' or 'م' — null when use24Hour is true.
String? formatPrayerPeriod(DateTime dt, {required bool use24Hour}) {
  if (use24Hour) return null;
  return dt.hour < 12 ? 'ص' : 'م';
}

String formatCountdown(Duration d) {
  if (d == Duration.zero) return '--:--';
  final h = d.inHours;
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:$m:$s';
  }
  return '$m:$s';
}

String formatIqamaCountdown(Duration d) {
  if (d == Duration.zero) return '--:--';
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
