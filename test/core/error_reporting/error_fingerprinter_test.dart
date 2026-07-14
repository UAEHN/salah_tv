import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/fingerprint/error_fingerprinter.dart';
import 'package:ghasaq/core/error_reporting/fingerprint/stack_frame_parser.dart';

void main() {
  const fingerprinter = ErrorFingerprinter();
  const parser = StackFrameParser();

  group(
    'fnv1a64Hex — shared vectors (MUST match functions/src/fingerprint.ts)',
    () {
      test('empty string yields the offset basis', () {
        expect(fnv1a64Hex(''), 'cbf29ce484222325');
      });

      test('"a"', () {
        expect(fnv1a64Hex('a'), 'af63dc4c8601ec8c');
      });

      test('"foobar"', () {
        expect(fnv1a64Hex('foobar'), '85944171f73967e8');
      });
    },
  );

  group('exception fingerprints', () {
    const stackAtLine73 = '''
#0      PrayerBloc._emitCurrent (package:ghasaq/features/prayer/presentation/bloc/prayer_bloc.dart:73:5)
#1      _rootRunUnary (dart:async/zone.dart:1407:47)
''';
    const stackAtLine95 = '''
#0      PrayerBloc._emitCurrent (package:ghasaq/features/prayer/presentation/bloc/prayer_bloc.dart:95:9)
#1      _rootRunUnary (dart:async/zone.dart:1407:47)
''';

    test('same site, different line → same fingerprint', () {
      final fp1 = fingerprinter.fingerprint(
        errorType: 'StateError',
        category: 'Prayer Engine',
        message: 'Bad state: no element',
        route: '/',
        topFrame: parser.topAppFrame(stackAtLine73),
      );
      final fp2 = fingerprinter.fingerprint(
        errorType: 'StateError',
        category: 'Prayer Engine',
        message: 'Bad state: no element',
        route: '/',
        topFrame: parser.topAppFrame(stackAtLine95),
      );
      expect(fp1, fp2);
    });

    test('different error type → different fingerprint', () {
      final fp1 = fingerprinter.fingerprint(
        errorType: 'StateError',
        category: 'Prayer Engine',
        message: 'x',
        route: '/',
        topFrame: parser.topAppFrame(stackAtLine73),
      );
      final fp2 = fingerprinter.fingerprint(
        errorType: 'RangeError',
        category: 'Prayer Engine',
        message: 'x',
        route: '/',
        topFrame: parser.topAppFrame(stackAtLine73),
      );
      expect(fp1, isNot(fp2));
    });
  });

  group('framework-only fallback (no app frame)', () {
    test('digits stripped: overflow by 42px and 17px group together', () {
      final fp42 = fingerprinter.fingerprint(
        errorType: 'FlutterError',
        category: 'UI Rendering',
        message: 'A RenderFlex overflowed by 42 pixels on the right.',
        route: '/',
        topFrame: null,
      );
      final fp17 = fingerprinter.fingerprint(
        errorType: 'FlutterError',
        category: 'UI Rendering',
        message: 'A RenderFlex overflowed by 17 pixels on the right.',
        route: '/',
        topFrame: null,
      );
      expect(fp42, fp17);
    });

    test('same message on a different route → different fingerprint', () {
      final fpHome = fingerprinter.fingerprint(
        errorType: 'FlutterError',
        category: 'UI Rendering',
        message: 'A RenderFlex overflowed by 42 pixels on the right.',
        route: '/',
        topFrame: null,
      );
      final fpSettings = fingerprinter.fingerprint(
        errorType: 'FlutterError',
        category: 'UI Rendering',
        message: 'A RenderFlex overflowed by 42 pixels on the right.',
        route: '/settings',
        topFrame: null,
      );
      expect(fpHome, isNot(fpSettings));
    });
  });

  group('silent-failure fingerprints', () {
    test('flow + failed step define the group', () {
      final fp1 = fingerprinter.silentFailureFingerprint(
        flow: 'adhan',
        failedStep: 'adhan_audio_started',
      );
      final fp2 = fingerprinter.silentFailureFingerprint(
        flow: 'adhan',
        failedStep: 'adhan_audio_started',
      );
      final fpOtherStep = fingerprinter.silentFailureFingerprint(
        flow: 'adhan',
        failedStep: 'alert_screen_shown',
      );
      expect(fp1, fp2);
      expect(fp1, isNot(fpOtherStep));
    });
  });

  group('native-crash fingerprints', () {
    test('same type + top frame → same group (line-independent)', () {
      final fp1 = fingerprinter.nativeCrashFingerprint(
        errorType: 'java.lang.IllegalStateException',
        topFrame: 'com.ghasaq.app.Foo.bar',
      );
      final fp2 = fingerprinter.nativeCrashFingerprint(
        errorType: 'java.lang.IllegalStateException',
        topFrame: 'com.ghasaq.app.Foo.bar',
      );
      expect(fp1, fp2);
    });

    test('different top frame → different group', () {
      final fp1 = fingerprinter.nativeCrashFingerprint(
        errorType: 'java.lang.IllegalStateException',
        topFrame: 'com.ghasaq.app.Foo.bar',
      );
      final fp2 = fingerprinter.nativeCrashFingerprint(
        errorType: 'java.lang.IllegalStateException',
        topFrame: 'com.ghasaq.app.Baz.qux',
      );
      expect(fp1, isNot(fp2));
    });

    test('key format is locked for the TS mirror', () {
      expect(
        fingerprinter.nativeCrashFingerprint(
          errorType: 'java.lang.NullPointerException',
          topFrame: 'com.ghasaq.app.X.y',
        ),
        fnv1a64Hex(
          'native_crash|java.lang.NullPointerException|com.ghasaq.app.X.y',
        ),
      );
    });
  });

  test('normalizeMessage strips digits and collapses whitespace', () {
    expect(
      ErrorFingerprinter.normalizeMessage('waited 1500 ms   for  frame 42'),
      'waited # ms for frame #',
    );
  });
}
