import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_mapper.dart';

void main() {
  const styledUrl =
      'https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/';
  const hafsUrl = 'https://server12.mp3quran.net/maher/';

  group('appSettingsFromMap reciter-choice migration gate', () {
    test('migrates a styled url to Hafs when choice is not explicit', () {
      final s = appSettingsFromMap({
        'quranReciterServerUrl': styledUrl,
        'hasExplicitReciterChoice': false,
      });
      expect(s.quranReciterServerUrl, hafsUrl);
      expect(s.hasExplicitReciterChoice, false);
    });

    test('preserves a deliberately chosen styled url (explicit choice)', () {
      final s = appSettingsFromMap({
        'quranReciterServerUrl': styledUrl,
        'hasExplicitReciterChoice': true,
      });
      expect(s.quranReciterServerUrl, styledUrl);
      expect(s.hasExplicitReciterChoice, true);
    });

    test('defaults to non-explicit (Hafs migration on) for old installs', () {
      // Old installs have no stored flag → must keep the safe Hafs behavior.
      final s = appSettingsFromMap({'quranReciterServerUrl': styledUrl});
      expect(s.quranReciterServerUrl, hafsUrl);
      expect(s.hasExplicitReciterChoice, false);
    });
  });
}
