import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/prayer_bloc.dart';

/// On-screen diagnostic for the live-clock freeze: when the engine tick throws,
/// the guard records the fault and this banner shows it (type + first stack
/// frame) at the bottom of the home screen so a non-technical tester can simply
/// screenshot the exact cause — no logcat, BigQuery, or adb needed.
///
/// TEST-BUILD ONLY: flip [_kEnabled] to `false` before a public release. It
/// renders nothing unless a fault has actually occurred, so it is invisible in
/// healthy operation, but the raw error text is not meant for end users.
const bool _kEnabled = true;

class TickErrorDiagnosticBanner extends StatelessWidget {
  const TickErrorDiagnosticBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!_kEnabled) return const SizedBox.shrink();
    final error = context.select((PrayerBloc b) => b.state.lastTickError);
    if (error == null) return const SizedBox.shrink();
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber, width: 1.5),
          ),
          child: Text(
            'TICK ERROR\n$error',
            textDirection: TextDirection.ltr,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
