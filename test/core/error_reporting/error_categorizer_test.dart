import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/classify/error_categorizer.dart';

void main() {
  const categorizer = ErrorCategorizer();

  ({String type, String message, String stack}) raw({
    String type = 'Exception',
    String message = '',
    String stack = '',
  }) => (type: type, message: message, stack: stack);

  final cases = <String, (({String type, String message, String stack}), String)>{
    'DioException → Content API': (
      raw(type: 'DioException', message: 'connection timeout'),
      ErrorCategories.contentApi,
    ),
    'SocketException → Content API': (
      raw(type: 'SocketException', message: 'Network is unreachable'),
      ErrorCategories.contentApi,
    ),
    'DatabaseException → Local Storage': (
      raw(type: 'DatabaseException', message: 'no such table'),
      ErrorCategories.localStorage,
    ),
    'sqflite stack → Local Storage': (
      raw(stack: '#0 x (package:sqflite/sqflite.dart:1:1)'),
      ErrorCategories.localStorage,
    ),
    'RenderFlex overflow → UI Rendering': (
      raw(
        type: 'FlutterError',
        message: 'A RenderFlex overflowed by 42 pixels',
      ),
      ErrorCategories.uiRendering,
    ),
    'PlatformException → Platform Channel': (
      raw(type: 'PlatformException'),
      ErrorCategories.platformChannel,
    ),
    'obfuscated audio setSource (type zha, empty stack) → Audio Playback': (
      raw(
        type: 'zha',
        message:
            'PlatformException(AndroidAudioError, Failed to set source. '
            'For troubleshooting, see: audioplayers/blob/main/'
            'troubleshooting.md, MEDIA_ERROR_UNKNOWN {what:1})',
      ),
      ErrorCategories.audioPlayback,
    ),
    'audio message wins over the generic PlatformException rule': (
      raw(type: 'PlatformException', message: 'AndroidAudioError: ...'),
      ErrorCategories.audioPlayback,
    ),
    'MissingPluginException → Platform Channel': (
      raw(type: 'MissingPluginException'),
      ErrorCategories.platformChannel,
    ),
    'firestore stack → Backend Sync': (
      raw(stack: '#0 x (package:cloud_firestore/cloud_firestore.dart:1:1)'),
      ErrorCategories.backendSync,
    ),
    'engine stack → Prayer Engine': (
      raw(
        stack:
            '#0 tick (package:ghasaq/features/prayer/domain/engine/tick_mixin.dart:31:5)',
      ),
      ErrorCategories.prayerEngine,
    ),
    'quran stack → Quran Playback': (
      raw(
        stack:
            '#0 f (package:ghasaq/features/quran/data/quran_api_service.dart:44:3)',
      ),
      ErrorCategories.quranPlayback,
    ),
    'audioplayers stack → Audio Playback': (
      raw(stack: '#0 x (package:audioplayers/audioplayers.dart:1:1)'),
      ErrorCategories.audioPlayback,
    ),
    'startup stack → Startup': (
      raw(
        stack: '#0 init (package:ghasaq/core/startup/startup_prayer.dart:10:3)',
      ),
      ErrorCategories.startup,
    ),
    'nothing matches → Unknown': (raw(), ErrorCategories.unknown),
    'FocusNode message → Remote Navigation': (
      raw(type: 'AssertionError', message: 'FocusNode was used after dispose'),
      ErrorCategories.remoteNavigation,
    ),
    // Regression guard (verified on-device 2026-07-03): a sync UI error whose
    // stack passes through the framework D-pad key machinery must NOT be
    // mislabeled Remote Navigation — that path is present in every TV UI error.
    'sync UI error through key dispatch → Unknown (not Remote Navigation)': (
      raw(
        type: '_Exception',
        message: 'Exception: something failed',
        stack:
            '#0 x (package:flutter/src/material/ink_well.dart:893:21)\n'
            '#1 y (package:flutter/src/widgets/shortcuts.dart:934:9)\n'
            '#2 z (package:flutter/src/widgets/focus_manager.dart:2243:72)\n'
            '#3 w (package:flutter/src/services/hardware_keyboard.dart:1122:34)',
      ),
      ErrorCategories.unknown,
    ),
    'DioException from a quran file still → Content API (type first)': (
      raw(
        type: 'DioException',
        stack:
            '#0 f (package:ghasaq/features/quran/data/quran_api_service.dart:44:3)',
      ),
      ErrorCategories.contentApi,
    ),
  };

  cases.forEach((description, testCase) {
    test(description, () {
      final (input, expected) = testCase;
      expect(
        categorizer.categorize(
          errorType: input.type,
          message: input.message,
          stack: input.stack,
        ),
        expected,
      );
    });
  });
}
