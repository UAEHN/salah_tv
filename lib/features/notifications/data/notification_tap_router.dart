import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge between native notification taps and the Flutter widget tree.
///
///  - Warm taps (app already running): native side invokes `onTap` on the
///    `ghasaq/notifications` MethodChannel. We push the payload onto
///    [warmAdhkarPayloadNotifier]; [MobileShell] reacts.
///
///  - Cold-start taps (app launched by tap): native side stashes the
///    payload; Flutter pulls it via `consumePendingTapPayload` after the
///    splash → home transition so back-press lands on home, not splash.
final ValueNotifier<String?> warmAdhkarPayloadNotifier = ValueNotifier<String?>(
  null,
);

const _channel = MethodChannel('ghasaq/notifications');

String? _pendingColdStartPayload;

/// Wires the warm-tap callback. Call once during startup before the first
/// frame so no taps are missed.
void initializeNotificationTapRouter() {
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'onTap') {
      final payload = call.arguments as String?;
      if (payload != null && payload.isNotEmpty) {
        warmAdhkarPayloadNotifier.value = payload;
      }
    }
    return null;
  });
}

/// Asks the native side for any payload buffered while the app was not
/// running. Call once after splash → home navigation completes.
Future<void> primeColdStartPayload() async {
  try {
    final payload = await _channel.invokeMethod<String>(
      'consumePendingTapPayload',
    );
    if (payload != null && payload.isNotEmpty) {
      _pendingColdStartPayload = payload;
    }
  } on PlatformException {
    // Channel may not be registered on TV — silently ignore.
  } on MissingPluginException {
    // Same as above.
  }
}

String? consumePendingColdStartPayload() {
  final p = _pendingColdStartPayload;
  _pendingColdStartPayload = null;
  return p;
}
