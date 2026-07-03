import '../domain/entities/quran_moshaf.dart';

/// Pure parsing helpers that turn a raw mp3quran `moshaf` array into the app's
/// recitation model. Extracted from [QuranApiService] to keep that file under
/// the 150-line limit (CLAUDE.md §4). No I/O — pure list/string transforms.

/// Selects the default complete (114-surah) recitation server for a reciter.
///
/// Some reciters publish several complete moshafs that differ by *style*
/// (e.g. «المصحف المجود», «المصحف المعلم») while only one is the plain
/// Hafs ʿan ʿAsim murattal the app defaults to. mp3quran does not order these
/// consistently — for Maher Al-Muaiqly and El-Minshawi the styled moshaf
/// now comes first — so we prefer the moshaf whose name names the Hafs
/// riwaya and fall back to the first complete moshaf when none is labelled.
String? pickServerUrl(List moshafs) {
  String? firstComplete;
  for (final m in moshafs) {
    if ((m['surah_total'] as int?) != 114) continue;
    final server = m['server'] as String?;
    if (server == null || server.isEmpty) continue;
    firstComplete ??= server;
    if ((m['name'] as String? ?? '').contains('حفص')) return server;
  }
  return firstComplete;
}

/// Every complete (114-surah) moshaf a reciter publishes, in API order.
/// Mirrors the filter in [pickServerUrl] (complete + non-empty server) but
/// keeps them all so the user can pick a طريقة instead of being collapsed
/// to the single default. Styled-name dedup («X - X» → «X») keeps labels tidy.
List<QuranMoshaf> completeMoshafs(List moshafs) {
  final result = <QuranMoshaf>[];
  for (final m in moshafs) {
    if ((m['surah_total'] as int?) != 114) continue;
    final server = m['server'] as String?;
    if (server == null || server.isEmpty) continue;
    result.add(
      QuranMoshaf(
        name: cleanMoshafName(m['name'] as String?),
        serverUrl: server,
      ),
    );
  }
  return result;
}

/// mp3quran often repeats the moshaf title («المصحف المجوّد - المصحف المجوّد»).
/// Collapse an exact «X - X» into «X»; otherwise return the trimmed name.
String cleanMoshafName(String? raw) {
  final name = (raw ?? '').trim();
  final dash = name.indexOf(' - ');
  if (dash > 0) {
    final left = name.substring(0, dash).trim();
    final right = name.substring(dash + 3).trim();
    if (left == right) return left;
  }
  return name;
}
