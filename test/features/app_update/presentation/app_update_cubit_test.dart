import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ghasaq/features/app_update/data/app_update_repository.dart';
import 'package:ghasaq/features/app_update/domain/whats_new_changelog.dart';

void main() {
  group('AppUpdateRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isCurrentVersionSeen returns false when nothing stored', () async {
      final repo = AppUpdateRepository();
      expect(await repo.isCurrentVersionSeen(), isFalse);
    });

    test('isCurrentVersionSeen returns false when a different version stored',
        () async {
      SharedPreferences.setMockInitialValues({
        'app_update_whats_new_seen_version': '0.0.1',
      });
      final repo = AppUpdateRepository();
      expect(await repo.isCurrentVersionSeen(), isFalse);
    });

    test('isCurrentVersionSeen returns true after markCurrentVersionSeen',
        () async {
      final repo = AppUpdateRepository();
      await repo.markCurrentVersionSeen();
      expect(await repo.isCurrentVersionSeen(), isTrue);
    });

    test('markCurrentVersionSeen stores kCurrentVersion', () async {
      final repo = AppUpdateRepository();
      await repo.markCurrentVersionSeen();

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('app_update_whats_new_seen_version'),
        kCurrentVersion,
      );
    });
  });
}
