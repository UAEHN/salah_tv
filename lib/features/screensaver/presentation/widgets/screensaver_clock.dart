import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../settings/presentation/settings_provider.dart';

/// Subtle clock shown in the corner of the screensaver so the time stays
/// glanceable while the prayer-times view is hidden. Updates only every 20s
/// (minute precision is enough) to keep the always-on screen cheap.
class ScreensaverClock extends StatefulWidget {
  final Color color;

  const ScreensaverClock({super.key, required this.color});

  @override
  State<ScreensaverClock> createState() => _ScreensaverClockState();
}

class _ScreensaverClockState extends State<ScreensaverClock> {
  Timer? _timer; // cancelled in dispose()
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final use24 = context.select<SettingsProvider, bool>(
      (p) => p.settings.use24HourFormat,
    );
    return Text(
      _format(_now, use24),
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w500,
        color: widget.color,
        letterSpacing: 1.5,
      ),
    );
  }

  String _format(DateTime t, bool use24) {
    final minute = t.minute.toString().padLeft(2, '0');
    if (use24) return '${t.hour.toString().padLeft(2, '0')}:$minute';
    final isPm = t.hour >= 12;
    var hour = t.hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute ${isPm ? 'م' : 'ص'}';
  }
}
