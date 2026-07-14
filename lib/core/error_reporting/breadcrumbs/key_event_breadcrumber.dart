import 'package:flutter/services.dart';

import '../domain/breadcrumb.dart';
import 'breadcrumb_recorder.dart';

/// Global hardware-key observer → `key` breadcrumbs (D-pad navigation is the
/// primary input on TV). Registered via [HardwareKeyboard.addHandler] and
/// ALWAYS returns false so it can never consume or delay a key event.
class KeyEventBreadcrumber {
  KeyEventBreadcrumber(this._recorder);

  final BreadcrumbRecorder _recorder;
  bool _isAttached = false;

  void attach() {
    if (_isAttached) return;
    HardwareKeyboard.instance.addHandler(_handle);
    _isAttached = true;
  }

  /// App-lifetime singleton — detached only in tests.
  void detach() {
    if (!_isAttached) return;
    HardwareKeyboard.instance.removeHandler(_handle);
    _isAttached = false;
  }

  bool _handle(KeyEvent event) {
    try {
      // KeyDown only: repeats collapse via the recorder's repeat counter,
      // and KeyUp would double every press.
      if (event is KeyDownEvent) {
        _recorder.add(
          Breadcrumb(
            at: DateTime.now(),
            type: BreadcrumbType.key,
            name: labelFor(event.logicalKey),
          ),
        );
      }
    } catch (_) {}
    return false; // Never consume input.
  }

  static String labelFor(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return 'dpad_up';
    if (key == LogicalKeyboardKey.arrowDown) return 'dpad_down';
    if (key == LogicalKeyboardKey.arrowLeft) return 'dpad_left';
    if (key == LogicalKeyboardKey.arrowRight) return 'dpad_right';
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      return 'select';
    }
    if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      return 'back';
    }
    if (key == LogicalKeyboardKey.contextMenu) return 'menu';
    if (key == LogicalKeyboardKey.mediaPlayPause) return 'play_pause';
    final label = key.keyLabel.trim();
    if (label.isNotEmpty) {
      return 'key_${label.toLowerCase().replaceAll(' ', '_')}';
    }
    return 'key_0x${key.keyId.toRadixString(16)}';
  }
}
