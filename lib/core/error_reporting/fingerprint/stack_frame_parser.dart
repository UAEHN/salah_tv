/// The topmost application frame extracted from a Dart stack trace.
class AppStackFrame {
  const AppStackFrame({required this.file, required this.member, this.line});

  /// Path inside the package, e.g. `features/prayer/presentation/x.dart`.
  final String file;

  /// Member name, e.g. `HomeScreen.build` (anonymous-closure suffixes
  /// stripped so the same site always yields the same member).
  final String member;

  final int? line;

  Map<String, Object?> toJson() => {
    'file': file,
    'member': member,
    'line': ?line,
  };
}

/// Extracts the first `package:ghasaq` frame from a VM stack trace string.
/// Frames inside `core/error_reporting/` are skipped so the reporting
/// pipeline never dominates a fingerprint. Returns null when no app frame
/// exists (pure framework errors like RenderFlex overflow).
class StackFrameParser {
  const StackFrameParser();

  static final RegExp _frameRe = RegExp(
    r'#\d+\s+(.+?)\s+\(package:ghasaq/([^\s:)]+\.dart)(?::(\d+))?(?::\d+)?\)',
  );

  AppStackFrame? topAppFrame(String stack) {
    for (final line in stack.split('\n')) {
      final match = _frameRe.firstMatch(line);
      if (match == null) continue;
      final file = match.group(2) ?? '';
      if (file.startsWith('core/error_reporting/')) continue;
      final member = _normalizeMember(match.group(1) ?? '');
      if (member.isEmpty || file.isEmpty) continue;
      return AppStackFrame(
        file: file,
        member: member,
        line: int.tryParse(match.group(3) ?? ''),
      );
    }
    return null;
  }

  /// Topmost native (JVM) frame from a native-crash stack, e.g.
  /// `com.ghasaq.app.Foo.bar(Foo.kt:12)` → file `com.ghasaq.app.Foo`,
  /// member `bar`, line 12. Returns a sentinel frame (never null) so callers
  /// stay simple. For JVM stacks only — Dart stacks use [topAppFrame].
  AppStackFrame topNativeFrame(String stack) {
    for (final raw in stack.split('\n')) {
      final line = raw.trim();
      if (!line.startsWith('at ')) continue;
      var frame = line.substring(3).trim();
      int? lineNo;
      final paren = frame.indexOf('(');
      if (paren > 0) {
        final location = frame.substring(paren + 1);
        lineNo = int.tryParse(
          RegExp(r':(\d+)\)').firstMatch(location)?.group(1) ?? '',
        );
        frame = frame.substring(0, paren).trim();
      }
      if (frame.isEmpty) continue;
      final dot = frame.lastIndexOf('.');
      return dot > 0
          ? AppStackFrame(
              file: frame.substring(0, dot),
              member: frame.substring(dot + 1),
              line: lineNo,
            )
          : AppStackFrame(file: frame, member: 'native', line: lineNo);
    }
    return const AppStackFrame(file: 'native', member: 'unknown');
  }

  /// `HomeScreen.build.<anonymous closure>` → `HomeScreen.build`.
  /// `new PrayerBloc` → `PrayerBloc` (constructor frames).
  static String _normalizeMember(String raw) {
    var member = raw.trim();
    while (member.endsWith('.<anonymous closure>')) {
      member = member.substring(
        0,
        member.length - '.<anonymous closure>'.length,
      );
    }
    if (member.startsWith('new ')) {
      member = member.substring(4);
    }
    return member;
  }
}
