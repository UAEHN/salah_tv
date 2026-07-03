import 'dart:io';
import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/platform_config.dart';
import '../domain/i_feedback_diagnostics_collector.dart';

/// Captures device-level facts at the moment a feedback message is sent:
/// app version, device type (TV vs phone), OS, and the device's actual
/// wall-clock + timezone — the data we need to diagnose timezone/clock
/// issues that depend on the user's environment.
class FeedbackDiagnosticsCollector implements IFeedbackDiagnosticsCollector {
  FeedbackDiagnosticsCollector({AppDiagnostics? diagnostics})
    : _diagnostics = diagnostics;

  final AppDiagnostics? _diagnostics;

  @override
  Future<Map<String, String>> collect() async {
    String version = '-';
    String build = '-';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      build = info.buildNumber;
    } catch (_) {
      // package_info_plus can fail on some custom Android TV ROMs — keep
      // submission usable rather than blocking the user.
    }

    final now = DateTime.now();
    final recent = await _diagnostics?.recent(limit: 30);
    return {
      'appVersion': '$version+$build',
      'deviceType': kIsTV ? 'tv' : 'phone',
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'deviceLocalTime': now.toIso8601String(),
      'deviceTimezone': now.timeZoneName,
      'deviceTimezoneOffsetMin': now.timeZoneOffset.inMinutes.toString(),
      'deviceLocale': Platform.localeName,
      if (recent != null && recent.isNotEmpty)
        'recentDiagnostics': jsonEncode(recent),
    };
  }
}
