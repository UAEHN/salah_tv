import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/domain/breadcrumb.dart';
import 'package:ghasaq/core/error_reporting/native/native_crash_bridge.dart';

import '../health/fake_error_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('ghasaq/platform');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late FakeErrorReporter reporter;
  String? markerReturn;

  final trail = [
    Breadcrumb(
      at: DateTime(2026, 7, 3, 5),
      type: BreadcrumbType.key,
      name: 'dpad_center',
    ),
  ];

  setUp(() {
    reporter = FakeErrorReporter();
    markerReturn = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'consumeNativeCrashMarker') return markerReturn;
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  NativeCrashBridge bridge() => NativeCrashBridge(service: reporter);

  test(
    'marker present → files a native crash with fields + previous trail',
    () async {
      markerReturn = jsonEncode({
        'error_type': 'java.lang.IllegalStateException',
        'message': 'boom',
        'thread': 'main',
        'stack':
            'java.lang.IllegalStateException: boom\n'
            '    at com.ghasaq.app.Foo.bar(Foo.kt:12)',
        'at': 1751500000000,
      });
      await bridge().consumeOnBoot(trail);

      expect(reporter.nativeCrashes, hasLength(1));
      final crash = reporter.nativeCrashes.single;
      expect(crash.errorType, 'java.lang.IllegalStateException');
      expect(crash.message, 'boom');
      expect(crash.stack, contains('com.ghasaq.app.Foo.bar'));
      expect(crash.breadcrumbs, trail);
      expect(crash.crashAt, DateTime.fromMillisecondsSinceEpoch(1751500000000));
    },
  );

  test('no marker → nothing reported', () async {
    markerReturn = null;
    await bridge().consumeOnBoot(trail);
    expect(reporter.nativeCrashes, isEmpty);
  });

  test('empty marker → nothing reported', () async {
    markerReturn = '';
    await bridge().consumeOnBoot(trail);
    expect(reporter.nativeCrashes, isEmpty);
  });

  test('malformed JSON is swallowed — no throw, no report', () async {
    markerReturn = '{not valid json';
    await bridge().consumeOnBoot(trail);
    expect(reporter.nativeCrashes, isEmpty);
  });

  test('non-object JSON is ignored', () async {
    markerReturn = '[1, 2, 3]';
    await bridge().consumeOnBoot(trail);
    expect(reporter.nativeCrashes, isEmpty);
  });

  test('missing error_type falls back; missing "at" → null crashAt', () async {
    markerReturn = jsonEncode({'message': 'x', 'stack': ''});
    await bridge().consumeOnBoot(const []);
    final crash = reporter.nativeCrashes.single;
    expect(crash.errorType, 'NativeCrash');
    expect(crash.crashAt, isNull);
  });
}
