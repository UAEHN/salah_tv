import 'package:flutter/widgets.dart';

import '../domain/breadcrumb.dart';
import 'breadcrumb_recorder.dart';

/// Observes D-pad focus traversal via [FocusManager] and records throttled
/// `focus` breadcrumbs (the widget the user is "standing on"). Focus churns
/// far faster than it informs, so changes within [_throttle] are dropped.
class FocusBreadcrumber {
  FocusBreadcrumber(this._recorder);

  final BreadcrumbRecorder _recorder;
  static const Duration _throttle = Duration(milliseconds: 400);

  bool _isAttached = false;
  FocusNode? _lastNode;
  DateTime? _lastAt;

  void attach() {
    if (_isAttached) return;
    FocusManager.instance.addListener(_onFocusChange);
    _isAttached = true;
  }

  /// App-lifetime singleton — detached only in tests.
  void detach() {
    if (!_isAttached) return;
    FocusManager.instance.removeListener(_onFocusChange);
    _isAttached = false;
  }

  void _onFocusChange() {
    try {
      final node = FocusManager.instance.primaryFocus;
      if (node == null || identical(node, _lastNode)) return;
      final now = DateTime.now();
      final lastAt = _lastAt;
      if (lastAt != null && now.difference(lastAt) < _throttle) {
        _lastNode = node; // Still remember it so settling doesn't re-fire.
        return;
      }
      _lastNode = node;
      _lastAt = now;
      _recorder.add(
        Breadcrumb(at: now, type: BreadcrumbType.focus, name: _labelOf(node)),
      );
    } catch (_) {}
  }

  static String _labelOf(FocusNode node) {
    final debugLabel = node.debugLabel;
    if (debugLabel != null && debugLabel.isNotEmpty) return debugLabel;
    final widgetType = node.context?.widget.runtimeType.toString();
    return widgetType ?? 'unlabeled_focus';
  }
}
