import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/breadcrumbs/breadcrumb_recorder.dart';
import 'package:ghasaq/core/error_reporting/bus/telemetry_bus.dart';
import 'package:ghasaq/core/error_reporting/bus/telemetry_event.dart';
import 'package:ghasaq/core/error_reporting/domain/breadcrumb.dart';

Breadcrumb crumb(String name, {String type = BreadcrumbType.key}) =>
    Breadcrumb(at: DateTime.now(), type: type, name: name);

void main() {
  test('ring is bounded: oldest dropped beyond capacity, order kept', () {
    final recorder = BreadcrumbRecorder(capacity: 5);
    for (var i = 0; i < 10; i++) {
      recorder.add(crumb('k$i'));
    }
    final trail = recorder.snapshot();
    expect(trail.length, 5);
    expect(trail.first.name, 'k5');
    expect(trail.last.name, 'k9');
  });

  test('consecutive same type+name collapse into one with repeat count', () {
    final recorder = BreadcrumbRecorder(capacity: 5);
    recorder.add(crumb('dpad_down'));
    recorder.add(crumb('dpad_down'));
    recorder.add(crumb('dpad_down'));
    recorder.add(crumb('select'));
    final trail = recorder.snapshot();
    expect(trail.length, 2);
    expect(trail.first.name, 'dpad_down');
    expect(trail.first.data?['repeat'], 3);
    expect(trail.last.name, 'select');
  });

  test('bus events become typed crumbs; noise + own events filtered', () async {
    final bus = TelemetryBus();
    final recorder = BreadcrumbRecorder()..attachTo(bus);
    bus.publish(
      source: TelemetrySource.diag,
      name: 'adhan_due_detected',
      params: {'prayer': 'fajr'},
    );
    bus.publish(source: TelemetrySource.analytics, name: 'tick_heartbeat');
    bus.publish(source: TelemetrySource.errorReporting, name: 'error_recorded');
    bus.publish(source: TelemetrySource.analytics, name: 'app_lifecycle');
    await Future<void>.delayed(Duration.zero);

    final trail = recorder.snapshot();
    expect(trail.length, 2);
    expect(trail.first.name, 'adhan_due_detected');
    expect(trail.first.type, BreadcrumbType.cycle);
    expect(trail.last.name, 'app_lifecycle');
    expect(trail.last.type, BreadcrumbType.lifecycle);

    await recorder.dispose();
    await bus.dispose();
  });

  test('param slimming drops identity noise and truncates values', () async {
    final bus = TelemetryBus();
    final recorder = BreadcrumbRecorder()..attachTo(bus);
    bus.publish(
      source: TelemetrySource.analytics,
      name: 'city_changed',
      params: {
        'session_id': 'abc',
        'installation_id': 'xyz',
        'city': 'Dubai',
        'note': 'x' * 100,
      },
    );
    await Future<void>.delayed(Duration.zero);

    final data = recorder.snapshot().single.data;
    expect(data, isNotNull);
    expect(data?.containsKey('session_id'), isFalse);
    expect(data?.containsKey('installation_id'), isFalse);
    expect(data?['city'], 'Dubai');
    expect((data?['note'] as String?)?.length, 60);

    await recorder.dispose();
    await bus.dispose();
  });
}
