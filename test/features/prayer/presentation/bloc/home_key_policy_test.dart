import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/prayer/presentation/bloc/home_key_policy.dart';

HomeKeyInput _input({
  required HomeRemoteKey key,
  bool isAfterPrayerAdhkar = false,
  bool isSessionAdhkar = false,
  bool isQuranEnabled = false,
  bool hasQuranReciter = false,
}) => HomeKeyInput(
  key: key,
  isAdhanPlaying: false,
  isDuaPlaying: false,
  isIqamaPlaying: false,
  isIqamaCountdown: false,
  isAfterPrayerAdhkar: isAfterPrayerAdhkar,
  isSessionAdhkar: isSessionAdhkar,
  isQuranEnabled: isQuranEnabled,
  hasQuranReciter: hasQuranReciter,
  canToggleTakbeerat: false,
);

void main() {
  group('adhkar takeover skip', () {
    test('select key skips the after-prayer adhkar', () {
      final intent = decideHomeKeyIntent(
        _input(key: HomeRemoteKey.select, isAfterPrayerAdhkar: true),
      );
      expect(intent, HomeKeyIntent.skipAfterPrayerAdhkar);
    });

    test('select key skips the session adhkar', () {
      final intent = decideHomeKeyIntent(
        _input(key: HomeRemoteKey.select, isSessionAdhkar: true),
      );
      expect(intent, HomeKeyIntent.skipSessionAdhkar);
    });

    test('media key also skips the takeover', () {
      final intent = decideHomeKeyIntent(
        _input(key: HomeRemoteKey.mediaPlayPause, isSessionAdhkar: true),
      );
      expect(intent, HomeKeyIntent.skipSessionAdhkar);
    });

    test('non-action key is swallowed during the takeover', () {
      final intent = decideHomeKeyIntent(
        _input(key: HomeRemoteKey.arrowDown, isSessionAdhkar: true),
      );
      expect(intent, HomeKeyIntent.ignored);
    });

    test('media key does NOT skip when no takeover is showing', () {
      // Quran enabled with a reciter → media key toggles Quran as before.
      final intent = decideHomeKeyIntent(
        _input(
          key: HomeRemoteKey.mediaPlayPause,
          isQuranEnabled: true,
          hasQuranReciter: true,
        ),
      );
      expect(intent, HomeKeyIntent.toggleQuran);
    });

    test('select key opens settings when no takeover is showing', () {
      final intent = decideHomeKeyIntent(_input(key: HomeRemoteKey.select));
      expect(intent, HomeKeyIntent.openSettings);
    });
  });
}
