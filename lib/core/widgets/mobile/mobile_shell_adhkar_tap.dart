import 'package:flutter/widgets.dart';

import '../../../features/adhkar/domain/entities/adhkar_session.dart';
import '../../../features/notifications/data/adhkar_payload.dart';
import '../../../features/notifications/data/notification_tap_router.dart';

AdhkarSession? _payloadToSession(String payload) {
  if (payload == AdhkarPayload.morning) return AdhkarSession.morning;
  if (payload == AdhkarPayload.evening) return AdhkarSession.evening;
  return null;
}

/// Cold-start path: read pending payload (if any) once after first frame and
/// hand a resolved session to [onSession]. No-op if there is no pending tap.
void consumeColdStartAdhkarPayload({
  required bool Function() isMounted,
  required void Function(AdhkarSession) onSession,
}) {
  final payload = consumePendingColdStartPayload();
  if (payload == null) return;
  final session = _payloadToSession(payload);
  if (session == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (isMounted()) onSession(session);
  });
}

/// Warm-tap path: subscribe to [warmAdhkarPayloadNotifier]. Returns the
/// detach function the caller must invoke in `dispose()`.
VoidCallback registerWarmAdhkarPayloadListener({
  required bool Function() isMounted,
  required void Function(AdhkarSession) onSession,
}) {
  void listener() {
    final payload = warmAdhkarPayloadNotifier.value;
    if (payload == null) return;
    warmAdhkarPayloadNotifier.value = null;
    final session = _payloadToSession(payload);
    if (session != null && isMounted()) onSession(session);
  }
  warmAdhkarPayloadNotifier.addListener(listener);
  return () => warmAdhkarPayloadNotifier.removeListener(listener);
}
