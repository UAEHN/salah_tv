import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_decoders.dart';

void main() {
  group('migrateToHafsReciterUrl', () {
    test('rewrites Maher «المجود» styled url to the Hafs base folder', () {
      expect(
        migrateToHafsReciterUrl(
          'https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/',
        ),
        'https://server12.mp3quran.net/maher/',
      );
    });

    test('rewrites Minshawi «المعلم» styled url to the Hafs base folder', () {
      expect(
        migrateToHafsReciterUrl(
          'https://server10.mp3quran.net/minsh/Almusshaf-Al-Mo-lim/',
        ),
        'https://server10.mp3quran.net/minsh/',
      );
    });

    test('leaves an already-Hafs base url unchanged (idempotent)', () {
      const url = 'https://server10.mp3quran.net/minsh/';
      expect(migrateToHafsReciterUrl(url), url);
      expect(migrateToHafsReciterUrl(migrateToHafsReciterUrl(url)), url);
    });

    test('leaves an unrelated reciter url unchanged', () {
      const url = 'https://server8.mp3quran.net/afs/';
      expect(migrateToHafsReciterUrl(url), url);
    });

    test('returns empty string untouched', () {
      expect(migrateToHafsReciterUrl(''), '');
    });
  });
}
