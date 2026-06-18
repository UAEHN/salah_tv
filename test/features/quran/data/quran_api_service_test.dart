import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/quran/data/quran_api_service.dart';

void main() {
  group('QuranApiService.pickServerUrl', () {
    test('prefers the Hafs moshaf when a styled moshaf comes first', () {
      // Mirrors mp3quran for Maher Al-Muaiqly: «المصحف المجود» is listed
      // before the plain «حفص عن عاصم - مرتل».
      final moshafs = [
        {
          'name': 'المصحف المجود - المصحف المجود',
          'surah_total': 114,
          'server':
              'https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/',
        },
        {
          'name': 'حفص عن عاصم - مرتل',
          'surah_total': 114,
          'server': 'https://server12.mp3quran.net/maher/',
        },
      ];

      expect(
        QuranApiService.pickServerUrl(moshafs),
        'https://server12.mp3quran.net/maher/',
      );
    });

    test('skips incomplete moshafs and still finds Hafs', () {
      final moshafs = [
        {
          'name': 'المصحف المعلم - المصحف المعلم',
          'surah_total': 38,
          'server': 'https://server10.mp3quran.net/x/Almusshaf-Al-Mo-lim/',
        },
        {
          'name': 'حفص عن عاصم - مرتل',
          'surah_total': 114,
          'server': 'https://server10.mp3quran.net/x/',
        },
      ];

      expect(
        QuranApiService.pickServerUrl(moshafs),
        'https://server10.mp3quran.net/x/',
      );
    });

    test('falls back to first complete moshaf when none is labelled Hafs', () {
      final moshafs = [
        {
          'name': 'ورش عن نافع - مرتل',
          'surah_total': 114,
          'server': 'https://server.mp3quran.net/warsh/',
        },
        {
          'name': 'قالون عن نافع - مرتل',
          'surah_total': 114,
          'server': 'https://server.mp3quran.net/qaloon/',
        },
      ];

      expect(
        QuranApiService.pickServerUrl(moshafs),
        'https://server.mp3quran.net/warsh/',
      );
    });

    test('returns null when there is no complete moshaf', () {
      final moshafs = [
        {
          'name': 'المصحف المعلم',
          'surah_total': 60,
          'server': 'https://server.mp3quran.net/partial/',
        },
      ];

      expect(QuranApiService.pickServerUrl(moshafs), isNull);
    });

    test('ignores complete moshafs with an empty server url', () {
      final moshafs = [
        {'name': 'حفص عن عاصم', 'surah_total': 114, 'server': ''},
        {
          'name': 'حفص عن عاصم - مرتل',
          'surah_total': 114,
          'server': 'https://server.mp3quran.net/ok/',
        },
      ];

      expect(
        QuranApiService.pickServerUrl(moshafs),
        'https://server.mp3quran.net/ok/',
      );
    });
  });
}
