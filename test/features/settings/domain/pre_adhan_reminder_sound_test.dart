import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_copy_with.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_decoders.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_mapper.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_notification_fields.dart';
import 'package:ghasaq/features/settings/domain/entities/custom_adhan.dart';

void main() {
  const custom = CustomAdhan(
    id: 'abc',
    label: 'reminder',
    fileName: 'abc.mp3',
    contentUri: 'content://media/external/audio/1',
  );

  group('preAdhanReminderSound default', () {
    test('every prayer defaults to silent', () {
      const s = AppSettings();
      expect(s.preAdhanReminderSound, const {
        'fajr': 'silent',
        'dhuhr': 'silent',
        'asr': 'silent',
        'maghrib': 'silent',
        'isha': 'silent',
      });
    });
  });

  group('copyWith', () {
    test('updates only the targeted prayer, leaving the rest silent', () {
      const base = AppSettings();
      final next = base.copyWith(
        preAdhanReminderSound: {
          ...base.preAdhanReminderSound,
          'fajr': custom.settingsKey,
        },
      );
      expect(next.preAdhanReminderSound['fajr'], 'custom:abc.mp3');
      expect(next.preAdhanReminderSound['dhuhr'], 'silent');
    });
  });

  group('mapper round-trip', () {
    test('preserves a custom per-prayer sound when the file still exists', () {
      final original = const AppSettings().copyWith(
        customAdhans: const [custom],
        preAdhanReminderSound: {
          'fajr': custom.settingsKey,
          'dhuhr': 'silent',
          'asr': 'silent',
          'maghrib': 'silent',
          'isha': 'silent',
        },
      );
      final restored = appSettingsFromMap(original.toMap());
      expect(restored.preAdhanReminderSound['fajr'], 'custom:abc.mp3');
      expect(restored.preAdhanReminderSound['isha'], 'silent');
    });
  });

  group('decodeReminderSoundMap validation', () {
    test('degrades a custom key to silent when the file no longer exists', () {
      final map = decodeReminderSoundMap(
        '{"fajr":"custom:missing.mp3","dhuhr":"silent","asr":"silent",'
        '"maghrib":"silent","isha":"silent"}',
        const [], // no imported sounds -> the referenced file is gone
      );
      expect(map['fajr'], 'silent');
    });

    test('keeps a custom key when its file exists', () {
      final map = decodeReminderSoundMap(
        '{"fajr":"custom:abc.mp3","dhuhr":"silent","asr":"silent",'
        '"maghrib":"silent","isha":"silent"}',
        const [custom],
      );
      expect(map['fajr'], 'custom:abc.mp3');
    });

    test('falls back to the default map on malformed JSON', () {
      expect(
        decodeReminderSoundMap('not json', const []),
        defaultReminderSoundMap,
      );
    });

    test('always returns a full 5-prayer map from a partial payload', () {
      final map = decodeReminderSoundMap('{"fajr":"silent"}', const []);
      expect(map.keys.toSet(), defaultReminderSoundMap.keys.toSet());
      expect(map['isha'], 'silent');
    });
  });

  group('equality helpers detect a reminder-sound change', () {
    const base = AppSettings();
    final changed = base.copyWith(
      preAdhanReminderSound: {
        ...base.preAdhanReminderSound,
        'fajr': 'custom:abc.mp3',
      },
    );

    test('notificationFieldsEqual is false (triggers reschedule)', () {
      expect(base.notificationFieldsEqual(changed), isFalse);
    });

    test('prayerFieldsEqual is false (notifies the engine bridge)', () {
      expect(base.prayerFieldsEqual(changed), isFalse);
    });
  });
}
