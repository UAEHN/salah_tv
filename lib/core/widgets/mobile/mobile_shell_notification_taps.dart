import 'package:flutter/widgets.dart';

import '../../../features/adhkar/domain/entities/adhkar_session.dart';
import '../../../features/notifications/data/adhkar_payload.dart';
import '../../../features/notifications/data/notification_tap_router.dart';

/// String payload used for the Friday Surah Al-Kahf reminder. Kept colocated
/// with the resolver so the routing rules live in one place.
const String _alKahfPayload = 'al_kahf';

AdhkarSession? _payloadToSession(String payload) {
  if (payload == AdhkarPayload.morning) return AdhkarSession.morning;
  if (payload == AdhkarPayload.evening) return AdhkarSession.evening;
  return null;
}

bool _isAlKahfPayload(String payload) => payload == _alKahfPayload;

/// Cold-start path: read pending payload (if any) once after first frame and
/// dispatch to the matching callback. No-op if there is no pending tap.
void consumeColdStartNotificationPayload({
  required bool Function() isMounted,
  required void Function(AdhkarSession) onAdhkar,
  required VoidCallback onAlKahf,
}) {
  final payload = consumePendingColdStartPayload();
  if (payload == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!isMounted()) return;
    final session = _payloadToSession(payload);
    if (session != null) {
      onAdhkar(session);
      return;
    }
    if (_isAlKahfPayload(payload)) onAlKahf();
  });
}

/// Warm-tap path: subscribe to [warmAdhkarPayloadNotifier]. Returns the
/// detach function the caller must invoke in `dispose()`.
VoidCallback registerWarmNotificationPayloadListener({
  required bool Function() isMounted,
  required void Function(AdhkarSession) onAdhkar,
  required VoidCallback onAlKahf,
}) {
  void listener() {
    final payload = warmAdhkarPayloadNotifier.value;
    if (payload == null) return;
    warmAdhkarPayloadNotifier.value = null;
    if (!isMounted()) return;
    final session = _payloadToSession(payload);
    if (session != null) {
      onAdhkar(session);
      return;
    }
    if (_isAlKahfPayload(payload)) onAlKahf();
  }
  warmAdhkarPayloadNotifier.addListener(listener);
  return () => warmAdhkarPayloadNotifier.removeListener(listener);
}
