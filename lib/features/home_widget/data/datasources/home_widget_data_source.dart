import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../../../core/error/failures.dart';
import '../models/widget_payload_mapper.dart';

/// Wraps the [HomeWidget] plugin so the repository depends on a stable
/// surface and is testable without the platform channel.
class HomeWidgetDataSource {
  static const String _appGroupId = 'com.ghasaq.app.widget';
  // All native widget providers consume the same SharedPreferences blob, so
  // every variant must be poked on every payload write/clear.
  static const List<String> _providerNames = [
    'PrayerWidgetProvider',
    'PrayerWidgetLargeProvider',
  ];

  Future<void> writeAll(WidgetPayloadFlat data) async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      for (final entry in data.strings.entries) {
        await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
      }
      for (final entry in data.longs.entries) {
        await HomeWidget.saveWidgetData<int>(entry.key, entry.value);
      }
      debugPrint(
        '[HomeWidget] wrote ${data.strings.length} strings + '
        '${data.longs.length} longs',
      );
      for (final name in _providerNames) {
        final result = await HomeWidget.updateWidget(
          name: name,
          androidName: name,
        );
        debugPrint('[HomeWidget] updateWidget($name) result: $result');
      }
    } catch (e, st) {
      debugPrint('[HomeWidget] write FAILED: $e\n$st');
      throw StorageException('home_widget write failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      for (final name in _providerNames) {
        await HomeWidget.updateWidget(name: name, androidName: name);
      }
    } catch (e) {
      throw StorageException('home_widget clear failed: $e');
    }
  }
}
