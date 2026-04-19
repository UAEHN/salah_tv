import 'package:flutter/material.dart';

/// Holds [GlobalKey]s for the mobile home screen elements
/// targeted by the first-time app tour spotlight.
class TourTargetKeys {
  final GlobalKey countdown = GlobalKey(debugLabel: 'tour_countdown');
  final GlobalKey prayerList = GlobalKey(debugLabel: 'tour_prayer_list');
  final GlobalKey dateNavigator = GlobalKey(debugLabel: 'tour_date_nav');
  final GlobalKey locationPill = GlobalKey(debugLabel: 'tour_location');
  final GlobalKey bottomNav = GlobalKey(debugLabel: 'tour_bottom_nav');
}

class TourTargetKeysProvider extends InheritedWidget {
  final TourTargetKeys keys;

  const TourTargetKeysProvider({
    super.key,
    required this.keys,
    required super.child,
  });

  static TourTargetKeys? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TourTargetKeysProvider>()
        ?.keys;
  }

  static TourTargetKeys of(BuildContext context) {
    final keys = maybeOf(context);
    assert(keys != null, 'No TourTargetKeysProvider found in context');
    return keys!;
  }

  @override
  bool updateShouldNotify(TourTargetKeysProvider oldWidget) =>
      keys != oldWidget.keys;
}
