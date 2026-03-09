import 'package:intl/intl.dart';

String formatPrayerTime(DateTime dt, {required bool use24Hour}) {
  return use24Hour
      ? DateFormat('HH:mm').format(dt)
      : DateFormat('hh:mm a').format(dt);
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
