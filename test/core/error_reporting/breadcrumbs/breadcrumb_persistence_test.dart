import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/breadcrumbs/breadcrumb_persistence.dart';
import 'package:ghasaq/core/error_reporting/breadcrumbs/breadcrumb_recorder.dart';
import 'package:ghasaq/core/error_reporting/domain/breadcrumb.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loadPrevious returns empty when nothing was persisted', () async {
    expect(await BreadcrumbPersistence().loadPrevious(), isEmpty);
  });

  test('a saved ring round-trips through loadPrevious', () async {
    final recorder = BreadcrumbRecorder()
      ..add(
        Breadcrumb(
          at: DateTime(2026, 7, 3, 5),
          type: BreadcrumbType.nav,
          name: '/home',
        ),
      )
      ..add(
        Breadcrumb(
          at: DateTime(2026, 7, 3, 5, 0, 1),
          type: BreadcrumbType.key,
          name: 'dpad_down',
          data: const {'repeat': '3'},
        ),
      );

    final saver = BreadcrumbPersistence(interval: const Duration(days: 1));
    saver.start(recorder);
    await saver.dispose(); // dispose() forces a final save

    final loaded = await BreadcrumbPersistence().loadPrevious();
    expect(loaded, hasLength(2));
    expect(loaded[0].name, '/home');
    expect(loaded[0].type, BreadcrumbType.nav);
    expect(loaded[1].name, 'dpad_down');
    expect(loaded[1].data?['repeat'], '3');
    expect(loaded[1].at, DateTime(2026, 7, 3, 5, 0, 1));
  });

  test('an empty ring is never written', () async {
    final saver = BreadcrumbPersistence(interval: const Duration(days: 1));
    saver.start(BreadcrumbRecorder());
    await saver.dispose();
    expect(await BreadcrumbPersistence().loadPrevious(), isEmpty);
  });

  test('Breadcrumb.fromJson tolerates missing fields', () {
    final crumb = Breadcrumb.fromJson(const {});
    expect(crumb.name, 'unknown');
    expect(crumb.type, BreadcrumbType.diag);
    expect(crumb.data, isNull);
  });
}
