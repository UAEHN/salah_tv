import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../injection.dart';
import '../bus/telemetry_bus.dart';
import '../bus/telemetry_event.dart';
import '../domain/error_severity.dart';
import '../domain/i_error_reporting_service.dart';

/// Debug-only pipeline verifier (reachable via `/error_test`, kDebugMode
/// route). Each button exercises a different capture path end-to-end:
/// sync → FlutterError.onError, async → zone handler, direct → service API.
/// Developer tool — intentionally not localized; never ships to users.
class ErrorTestScreen extends StatelessWidget {
  const ErrorTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Reporting Test')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TestButton(
                label: 'Throw sync exception (FlutterError.onError)',
                isAutofocused: true,
                onPressed: _throwSync,
              ),
              const SizedBox(height: 12),
              _TestButton(
                label: 'Throw async exception (zone handler)',
                onPressed: _throwAsync,
              ),
              const SizedBox(height: 12),
              _TestButton(
                label: 'Report handled error (direct service call)',
                onPressed: _reportHandled,
              ),
              const SizedBox(height: 12),
              _TestButton(
                label:
                    'Synthetic silent failure (adhan screen shown, no sound; '
                    '~8s → Fatal)',
                onPressed: _triggerSyntheticSilentFailure,
              ),
              const SizedBox(height: 24),
              const Text(
                'Expected result: a document appears in the Firestore '
                '"error_events" collection (offline: queued in '
                'error_queue.db and uploaded on reconnect).',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _throwSync() {
    throw StateError('Test sync error from ErrorTestScreen');
  }

  static void _throwAsync() {
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      throw StateError('Test async zone error from ErrorTestScreen');
    });
  }

  static void _reportHandled() {
    if (!getIt.isRegistered<IErrorReportingService>()) return;
    getIt<IErrorReportingService>().reportError(
      name: 'manual_test_error',
      error: Exception('Manually reported test error'),
      stack: StackTrace.current,
      severity: ErrorSeverity.error,
    );
  }

  /// Publishes adhan FIRED + the screen-rendered signal, then nothing. The
  /// FunctionalHealthMonitor advances the flow past the screen step and arms
  /// the audio timer, which expires (~8s) → the flagship "screen shown but no
  /// sound" Fatal silent failure. A full end-to-end check of Layer 3 without
  /// waiting for a real prayer time.
  static void _triggerSyntheticSilentFailure() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<TelemetryBus>()) return;
    final bus = getIt<TelemetryBus>();
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'adhan_journey_state',
      params: {
        'prayer_key': 'dhuhr',
        'adhan_final_state': 'FIRED',
        'stage': 'debug_synthetic',
      },
    );
    bus.publish(
      source: TelemetrySource.diag,
      name: 'alert_screen_rendered',
      params: {'flow': 'adhan', 'prayer_key': 'dhuhr'},
    );
  }
}

class _TestButton extends StatelessWidget {
  const _TestButton({
    required this.label,
    required this.onPressed,
    this.isAutofocused = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isAutofocused;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      autofocus: isAutofocused,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
