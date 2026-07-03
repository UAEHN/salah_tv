import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/quran/data/quran_moshaf_parser.dart';

void main() {
  group('pickServerUrl', () {
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

      expect(pickServerUrl(moshafs), 'https://server12.mp3quran.net/maher/');
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

      expect(pickServerUrl(moshafs), 'https://server10.mp3quran.net/x/');
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

      expect(pickServerUrl(moshafs), 'https://server.mp3quran.net/warsh/');
    });

    test('returns null when there is no complete moshaf', () {
      final moshafs = [
        {
          'name': 'المصحف المعلم',
          'surah_total': 60,
          'server': 'https://server.mp3quran.net/partial/',
        },
      ];

      expect(pickServerUrl(moshafs), isNull);
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

      expect(pickServerUrl(moshafs), 'https://server.mp3quran.net/ok/');
    });
  });

  group('completeMoshafs', () {
    test('keeps every complete moshaf in API order', () {
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

      final result = completeMoshafs(moshafs);

      expect(result.length, 2);
      expect(
        result[0].serverUrl,
        'https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/',
      );
      expect(result[1].serverUrl, 'https://server12.mp3quran.net/maher/');
    });

    test('drops incomplete and empty-server moshafs', () {
      final moshafs = [
        {
          'name': 'المصحف المعلم',
          'surah_total': 38,
          'server': 'https://server.mp3quran.net/partial/',
        },
        {'name': 'حفص', 'surah_total': 114, 'server': ''},
        {
          'name': 'حفص عن عاصم - مرتل',
          'surah_total': 114,
          'server': 'https://server.mp3quran.net/ok/',
        },
      ];

      final result = completeMoshafs(moshafs);

      expect(result.length, 1);
      expect(result.single.serverUrl, 'https://server.mp3quran.net/ok/');
    });
  });

  group('cleanMoshafName', () {
    test('collapses an exact «X - X» duplicate into «X»', () {
      expect(cleanMoshafName('المصحف المجود - المصحف المجود'), 'المصحف المجود');
    });

    test('keeps a genuine «riwaya - style» label intact', () {
      expect(cleanMoshafName('حفص عن عاصم - مرتل'), 'حفص عن عاصم - مرتل');
    });

    test('trims and tolerates null', () {
      expect(cleanMoshafName('  ورش  '), 'ورش');
      expect(cleanMoshafName(null), '');
    });
  });
}
