import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'flow_outcome.dart';

/// Writes one `flow_runs` document per adhan/iqama run — the denominator the
/// dashboard divides failures by to show "adhan playback succeeded X% today".
///
/// Best-effort direct write (unlike error_events, these aren't queued
/// offline): a lost success stat only slightly blurs an aggregate rate,
/// whereas failures always travel through the durable error_events queue.
/// Reads identity/context lazily so the install id (set after startup) and
/// live mosque mode are always current.
class FlowRunRecorder implements FlowRunSink {
  FlowRunRecorder({
    required Map<String, Object?> Function() appContextProvider,
    required Map<String, Object?> Function() settingsContextProvider,
    required DateTime Function() clock,
    FirebaseFirestore? firestore,
  }) : _appContext = appContextProvider,
       _settingsContext = settingsContextProvider,
       _clock = clock,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final Map<String, Object?> Function() _appContext;
  final Map<String, Object?> Function() _settingsContext;
  final DateTime Function() _clock;
  final FirebaseFirestore _firestore;

  static const _collection = 'flow_runs';
  static const Duration _retention = Duration(days: 14);
  static const Duration _timeout = Duration(seconds: 12);

  @override
  void record(FlowOutcome outcome, {required bool silentMode}) {
    // Only the two audio funnels have a success/failure denominator; sequence
    // and countdown incidents are recorded solely as error_events.
    if (outcome.flow != 'adhan' && outcome.flow != 'iqama') return;
    final now = _clock();
    final app = _appContext();
    final payload = <String, Object?>{
      'flow': outcome.flow,
      'prayer_key': outcome.prayerKey,
      'date_key': _dateKey(now),
      'install_id': app['install_id']?.toString() ?? 'unknown',
      'app_version': app['version']?.toString() ?? 'unknown',
      'result': outcome.result.name,
      'failed_step': ?outcome.failedStep,
      'waited_ms': outcome.waitedMs,
      'silent_mode': silentMode,
      'mosque_mode': _settingsContext()['is_mosque_mode'] == true,
      'at': FieldValue.serverTimestamp(),
      'expire_at': Timestamp.fromDate(now.add(_retention)),
    };
    try {
      unawaited(
        _firestore
            .collection(_collection)
            .add(payload)
            .timeout(_timeout)
            .then((_) {}, onError: (_) {}),
      );
    } catch (_) {}
  }

  String _dateKey(DateTime now) {
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
