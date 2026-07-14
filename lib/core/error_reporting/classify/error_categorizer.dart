/// Human-readable categories shown in the Control Room. Wire values —
/// renaming one is a schema change for the dashboard filters.
class ErrorCategories {
  const ErrorCategories._();

  static const String audioPlayback = 'Audio Playback';
  static const String quranPlayback = 'Quran Playback';
  static const String remoteNavigation = 'Remote Navigation';
  static const String contentApi = 'Content API';
  static const String localStorage = 'Local Storage';
  static const String uiRendering = 'UI Rendering';
  static const String prayerEngine = 'Prayer Engine';
  static const String platformChannel = 'Platform Channel';
  static const String backendSync = 'Backend Sync';
  static const String functionalHealth = 'Functional Health';
  static const String startup = 'Startup';
  static const String unknown = 'Unknown';
}

/// Maps an error + stack to a category. Order matters: the first matching
/// rule wins, and type-based rules run before stack-path heuristics so a
/// DioException thrown from a quran file still lands in Content API.
class ErrorCategorizer {
  const ErrorCategorizer();

  String categorize({
    required String errorType,
    required String message,
    required String stack,
  }) {
    if (_typeIs(errorType, const ['DioException', 'DioError']) ||
        _has(message, 'SocketException') ||
        _typeIs(errorType, const ['SocketException', 'HttpException'])) {
      return ErrorCategories.contentApi;
    }
    if (_typeIs(errorType, const ['DatabaseException', 'StorageException']) ||
        _has(stack, 'package:sqflite') ||
        _has(stack, 'package:shared_preferences')) {
      return ErrorCategories.localStorage;
    }
    if (_has(message, 'RenderFlex') ||
        _has(message, 'RenderBox') ||
        _has(message, 'overflowed') ||
        _has(stack, 'package:flutter/src/rendering')) {
      return ErrorCategories.uiRendering;
    }
    // audioplayers/just_audio surface a native MediaPlayer failure as a wrapped
    // PlatformException whose type is obfuscated in release ('zha') and whose
    // stack is native-only — so match the message, BEFORE the generic
    // PlatformException rule, to keep audio errors out of Platform Channel /
    // Unknown. See features/audio/data/audio_stream_guard.dart.
    if (_has(message, 'AndroidAudioError') ||
        _has(message, 'Failed to set source') ||
        _has(message, 'audioplayers') ||
        _has(message, 'MEDIA_ERROR') ||
        _has(message, 'just_audio')) {
      return ErrorCategories.audioPlayback;
    }
    if (_typeIs(errorType, const [
      'PlatformException',
      'MissingPluginException',
    ])) {
      return ErrorCategories.platformChannel;
    }
    if (_has(stack, 'package:cloud_firestore') ||
        _has(stack, 'package:firebase_') ||
        _typeIs(errorType, const ['FirebaseException'])) {
      return ErrorCategories.backendSync;
    }
    if (_has(stack, 'prayer/domain/engine') ||
        _has(stack, 'prayer_cycle_engine')) {
      return ErrorCategories.prayerEngine;
    }
    if (_has(stack, 'features/quran/') || _has(stack, 'quran_api')) {
      return ErrorCategories.quranPlayback;
    }
    if (_has(stack, 'features/audio/') ||
        _has(stack, 'package:audioplayers') ||
        _has(stack, 'package:just_audio')) {
      return ErrorCategories.audioPlayback;
    }
    if (_has(stack, 'app_startup') || _has(stack, 'core/startup/')) {
      return ErrorCategories.startup;
    }
    // Remote Navigation ONLY when the app's own focus/navigation code or the
    // message is about focus — NOT merely because the framework's D-pad key
    // dispatch (focus_manager / hardware_keyboard / shortcuts / ink_well) is
    // on the stack. Verified 2026-07-03: EVERY synchronous UI error on a TV
    // routes through that machinery, so matching it mislabels all of them.
    if (_has(message, 'FocusNode') ||
        _has(message, 'focus node') ||
        _has(stack, 'package:ghasaq/core/navigation') ||
        _has(stack, 'features/onboarding/presentation/focus')) {
      return ErrorCategories.remoteNavigation;
    }
    return ErrorCategories.unknown;
  }

  static bool _typeIs(String errorType, List<String> names) =>
      names.contains(errorType);

  static bool _has(String haystack, String needle) => haystack.contains(needle);
}
