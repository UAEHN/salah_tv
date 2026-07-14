/// Static pattern → one-sentence hint table for recognizable Flutter /
/// Android TV error shapes. Matched on lowercase `errorType + message`.
/// Purely informational — shown in the Control Room drill-down.
class LikelyCauseHints {
  const LikelyCauseHints._();

  static const List<(String, String)> _patterns = [
    (
      'renderflex overflowed',
      'RenderFlex overflow — check widget constraints on this screen.',
    ),
    (
      'renderbox was not laid out',
      'Widget rendered before layout — check unbounded constraints.',
    ),
    (
      'missingpluginexception',
      'Platform channel not registered — native side missing '
          '(or a hot-restart artifact in debug).',
    ),
    (
      'setstate() called after dispose',
      'setState after dispose — missing `if (!mounted) return;` '
          'after an await.',
    ),
    (
      'lateinitializationerror',
      'Late field read before initialization — check init order.',
    ),
    (
      'socketexception',
      'Network unreachable — device offline, DNS failure, or server down.',
    ),
    (
      'connection timed out',
      'Network timeout — slow TV-box WiFi or unresponsive server.',
    ),
    ('timeoutexception', 'Operation timed out — slow network or blocked I/O.'),
    (
      "type 'null' is not a subtype",
      'Null value where non-null expected — missing null guard.',
    ),
    ('rangeerror', 'Index out of bounds — list accessed past its length.'),
    (
      'formatexception',
      'Malformed data during parsing — check the payload shape.',
    ),
    ('permission-denied', 'Firestore security rules rejected this operation.'),
    (
      'no such table',
      'SQLite schema mismatch — migration missing for this table.',
    ),
    (
      'out of memory',
      'Memory pressure — TV box exhausted heap; check image/audio caches.',
    ),
  ];

  static String? hintFor({required String errorType, required String message}) {
    final haystack = '$errorType $message'.toLowerCase();
    for (final (needle, hint) in _patterns) {
      if (haystack.contains(needle)) return hint;
    }
    return null;
  }
}
