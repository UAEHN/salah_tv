import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../bus/telemetry_bus.dart';
import '../bus/telemetry_event.dart';

/// Emits the ONLY new signal the functional-health layer needs: proof that an
/// alert screen actually reached the frame buffer. The engine's
/// `NOTIFICATION_SHOWN` fires when it flips a flag — not when the widget
/// paints — so wrapping the adhan/iqama takeover in this reporter closes the
/// "flag set but nothing rendered" blind spot.
///
/// Fires `alert_screen_rendered {flow, prayer_key}` exactly once per State
/// lifetime via a post-frame callback; a keyed instance per prayer guarantees
/// a fresh State (and a fresh signal) for each run.
class FirstFrameReporter extends StatefulWidget {
  const FirstFrameReporter({
    required this.flow,
    required this.prayerKey,
    required this.child,
    super.key,
  });

  final String flow;
  final String prayerKey;
  final Widget child;

  @override
  State<FirstFrameReporter> createState() => _FirstFrameReporterState();
}

class _FirstFrameReporterState extends State<FirstFrameReporter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _report();
    });
  }

  void _report() {
    try {
      final getIt = GetIt.instance;
      if (!getIt.isRegistered<TelemetryBus>()) return;
      getIt<TelemetryBus>().publish(
        source: TelemetrySource.diag,
        name: 'alert_screen_rendered',
        params: {'flow': widget.flow, 'prayer_key': widget.prayerKey},
      );
    } catch (_) {
      // A reporting failure must never affect what the user sees.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
