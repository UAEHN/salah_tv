import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_copy_with.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_notification_fields.dart';

void main() {
  group('AppSettings.notificationFieldsEqual', () {
    const base = AppSettings();

    test('equal to itself', () {
      expect(base.notificationFieldsEqual(base), isTrue);
    });

    test('detects a pre-adhan minutes change', () {
      final other = base.copyWith(
        preAdhanReminderMinutes: base.preAdhanReminderMinutes + 5,
      );
      expect(base.notificationFieldsEqual(other), isFalse);
    });

    test('detects a pre-adhan enabled-map change', () {
      final other = base.copyWith(
        preAdhanReminderEnabled: const {
          'fajr': true,
          'dhuhr': true,
          'asr': true,
          'maghrib': true,
          'isha': true,
        },
      );
      expect(base.notificationFieldsEqual(other), isFalse);
    });

    test('detects a pre-iqama minutes change', () {
      final other = base.copyWith(
        preIqamaReminderMinutes: base.preIqamaReminderMinutes + 3,
      );
      expect(base.notificationFieldsEqual(other), isFalse);
    });

    test('ignores a non-notification field (locale)', () {
      final other = base.copyWith(locale: base.locale == 'ar' ? 'en' : 'ar');
      expect(base.notificationFieldsEqual(other), isTrue);
    });
  });
}
