import 'package:intl/intl.dart';

String formatPrayerTime(
  DateTime dt, {
  required bool use24Hour,
  String? localeCode,
}) {
  // Always use 'en' for digits so Arabic locale doesn't produce ٣:٠٠ etc.
  if (use24Hour) return DateFormat('HH:mm', 'en').format(dt);
  return DateFormat('hh:mm', 'en').format(dt);
}

/// Returns the localized day period (AM/PM) for 12-hour format.
String? formatPrayerPeriod(
  DateTime dt, {
  required bool use24Hour,
  String? localeCode,
}) {
  if (use24Hour) return null;
  return DateFormat('a', localeCode).format(dt);
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
