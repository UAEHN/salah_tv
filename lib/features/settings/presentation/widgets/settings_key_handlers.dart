import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

KeyEventResult handleSettingsNavKeyEvent(
  FocusScopeNode contentScopeNode,
  KeyEvent event,
) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }
  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    contentScopeNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (contentScopeNode.hasPrimaryFocus) contentScopeNode.nextFocus();
    });
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
}

KeyEventResult handleSettingsContentKeyEvent(
  List<FocusNode> navFocusNodes,
  int selectedIndex,
  KeyEvent event,
) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowDown) {
    final direction =
        key == LogicalKeyboardKey.arrowDown ? TraversalDirection.down : TraversalDirection.up;
    FocusManager.instance.primaryFocus?.focusInDirection(direction);
    return KeyEventResult.handled;
  }
  if (key == LogicalKeyboardKey.arrowRight) {
    final moved =
        FocusManager.instance.primaryFocus?.focusInDirection(TraversalDirection.right) ?? false;
    if (!moved) navFocusNodes[selectedIndex].requestFocus();
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
}
