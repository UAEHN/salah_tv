import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/fingerprint/stack_frame_parser.dart';

void main() {
  const parser = StackFrameParser();

  test('extracts the first app frame with file, member and line', () {
    const stack = '''
#0      AudioService._playMain (package:ghasaq/features/audio/data/audio_service.dart:98:7)
#1      AudioService.playAdhan (package:ghasaq/features/audio/data/audio_service.dart:120:12)
#2      _rootRunUnary (dart:async/zone.dart:1407:47)
''';
    final frame = parser.topAppFrame(stack);
    expect(frame, isNotNull);
    expect(frame?.file, 'features/audio/data/audio_service.dart');
    expect(frame?.member, 'AudioService._playMain');
    expect(frame?.line, 98);
  });

  test('skips frames inside core/error_reporting', () {
    const stack = '''
#0      ErrorReportingService.reportError (package:ghasaq/core/error_reporting/error_reporting_service.dart:52:7)
#1      HomeScreen.build (package:ghasaq/features/prayer/presentation/screens/home_screen.dart:251:12)
''';
    final frame = parser.topAppFrame(stack);
    expect(
      frame?.file,
      'features/prayer/presentation/screens/home_screen.dart',
    );
    expect(frame?.member, 'HomeScreen.build');
  });

  test('framework-only stack yields null', () {
    const stack = '''
#0      RenderFlex.performLayout (package:flutter/src/rendering/flex.dart:900:15)
#1      RenderObject.layout (package:flutter/src/rendering/object.dart:2620:7)
#2      _invoke (dart:ui/hooks.dart:312:13)
''';
    expect(parser.topAppFrame(stack), isNull);
  });

  test('anonymous-closure suffixes are stripped from the member', () {
    const stack = '''
#0      HomeScreen.build.<anonymous closure>.<anonymous closure> (package:ghasaq/features/prayer/presentation/screens/home_screen.dart:120:20)
''';
    expect(parser.topAppFrame(stack)?.member, 'HomeScreen.build');
  });

  test('constructor frames drop the "new " prefix', () {
    const stack = '''
#0      new PrayerBloc (package:ghasaq/features/prayer/presentation/bloc/prayer_bloc.dart:30:5)
''';
    expect(parser.topAppFrame(stack)?.member, 'PrayerBloc');
  });

  test('async suspension gaps are ignored', () {
    const stack = '''
<asynchronous suspension>
#0      QuranApiService.fetch (package:ghasaq/features/quran/data/quran_api_service.dart:44:3)
<asynchronous suspension>
''';
    expect(
      parser.topAppFrame(stack)?.file,
      'features/quran/data/quran_api_service.dart',
    );
  });

  group('topNativeFrame (JVM crash stacks)', () {
    test('parses class + method + line, dropping the file location', () {
      const stack = '''
java.lang.IllegalStateException: boom
    at com.ghasaq.app.Foo.bar(Foo.kt:42)
    at com.ghasaq.app.MainActivity.onCreate(MainActivity.kt:50)
''';
      final frame = parser.topNativeFrame(stack);
      expect(frame.file, 'com.ghasaq.app.Foo');
      expect(frame.member, 'bar');
      expect(frame.line, 42);
    });

    test('a native method with no line number yields a null line', () {
      const stack = '''
java.lang.RuntimeException
    at android.os.MessageQueue.nativePollOnce(Native Method)
''';
      final frame = parser.topNativeFrame(stack);
      expect(frame.file, 'android.os.MessageQueue');
      expect(frame.member, 'nativePollOnce');
      expect(frame.line, isNull);
    });

    test('no parseable frame → sentinel frame (never null)', () {
      final frame = parser.topNativeFrame('a message with no frames');
      expect(frame.file, 'native');
      expect(frame.member, 'unknown');
    });
  });
}
