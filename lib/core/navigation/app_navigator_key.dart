import 'package:flutter/widgets.dart';

/// Top-level navigator key shared across the app. Used by background
/// callbacks (e.g. notification taps) that need to push a route without a
/// `BuildContext`.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
