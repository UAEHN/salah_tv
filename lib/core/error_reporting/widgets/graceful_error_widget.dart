import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../diagnostics/app_diagnostics.dart';
import '../../diagnostics/diagnostic_level.dart' as diag;

/// Replaces Flutter's default error box (grey in release / red in debug) with a
/// calm, self-contained screen that is GUARANTEED to paint on any device — even
/// a weak TV box whose real screen threw a layout error (RenderBox on an odd
/// resolution). Set as `ErrorWidget.builder` so a build/layout failure anywhere
/// (including the adhan takeover) never leaves the user staring at a blank box.
///
/// It is also a diagnostic: reaching this widget means a real screen failed to
/// render, so it records `render_error_fallback_shown` (throttled) — turning an
/// invisible blank into a named, located signal we can see in the dashboard.
class GracefulErrorWidget extends StatelessWidget {
  const GracefulErrorWidget({required this.details, super.key});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    _reportFallbackShown(details);
    // Deliberately dependency-free: no Material, no localization, no theme
    // lookup — any of those could be the very thing that failed. Just a colored
    // box and text with an explicit direction/style so it cannot itself throw.
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: ColoredBox(
        color: Color(0xFF0E1A24),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'لحظة من فضلك…',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE8EEF3),
                fontSize: 24,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A layout error re-throws on every layout pass, so the builder can fire many
// times a second — throttle the diagnostic so it never floods the queue.
DateTime? _lastFallbackReport;

void _reportFallbackShown(FlutterErrorDetails details) {
  try {
    final now = DateTime.now();
    final last = _lastFallbackReport;
    if (last != null && now.difference(last) < const Duration(seconds: 10)) {
      return;
    }
    _lastFallbackReport = now;
    if (!GetIt.I.isRegistered<AppDiagnostics>()) return;
    GetIt.I<AppDiagnostics>().record(
      diag.DiagnosticLevel.warning,
      'render_error_fallback_shown',
      fields: {
        'library': details.library ?? 'unknown',
        'summary': details.exceptionAsString().split('\n').first,
      },
      forceUpload: true,
    );
  } catch (_) {
    // The last-resort error widget must never throw.
  }
}
