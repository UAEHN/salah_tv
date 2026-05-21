// ignore_for_file: avoid_print
// One-shot converter: Tanzil XML → assets/quran/quran_uthmani.json
//
// USAGE:
//   dart run tool/quran_xml_to_json.dart <quran-text.xml> <quran-data.xml>
//
// Inputs:
//   1. Tanzil text file: quran-uthmani.xml.
//   2. Tanzil metadata file: quran-data.xml. We use its <page>, <juz>,
//      <quarter> (240 rub-el-hizb starts) and <sajda> elements.
//
// Output: assets/quran/quran_uthmani.json — flat list of 6236 ayahs each
// carrying page+juz, plus optional `sajdah` ("recommended"|"obligatory")
// and `quarter` (1..240) when the ayah is a marker position.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Usage: dart run tool/quran_xml_to_json.dart '
        '<text.xml> <quran-data.xml>');
    exit(64);
  }

  final textXml = File(args[0]).readAsStringSync();
  final dataXml = File(args[1]).readAsStringSync();

  final pageStarts = _parseStarts(dataXml, tag: 'page');
  final juzStarts = _parseStarts(dataXml, tag: 'juz');
  final quarterMarks = _parseQuarterMap(dataXml);
  final sajdaMarks = _parseSajdaMap(dataXml);

  if (pageStarts.length != 604) {
    stderr.writeln('warning: expected 604 page entries, got '
        '${pageStarts.length}');
  }
  if (juzStarts.length != 30) {
    stderr.writeln('warning: expected 30 juz entries, got ${juzStarts.length}');
  }
  if (quarterMarks.length != 240) {
    stderr.writeln('warning: expected 240 quarter entries, got '
        '${quarterMarks.length}');
  }
  if (sajdaMarks.length != 15) {
    stderr.writeln('warning: expected 15 sajda entries, got '
        '${sajdaMarks.length}');
  }

  final ayahs = _parseAyahs(textXml);
  for (final a in ayahs) {
    final key = _key(a['surah'] as int, a['ayah'] as int);
    a['page'] = _resolveStart(pageStarts, a['surah'] as int, a['ayah'] as int);
    a['juz'] = _resolveStart(juzStarts, a['surah'] as int, a['ayah'] as int);
    final q = quarterMarks[key];
    if (q != null) a['quarter'] = q;
    final s = sajdaMarks[key];
    if (s != null) a['sajdah'] = s;
  }

  final out = File('assets/quran/quran_uthmani.json');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(jsonEncode({'ayahs': ayahs}));
  print('Wrote ${ayahs.length} ayahs to ${out.path}');
}

final _ayaRe = RegExp(
  r'<aya index="(\d+)" text="([^"]+)"',
  unicode: true,
);
final _suraRe = RegExp(r'<sura index="(\d+)"', unicode: true);

List<Map<String, dynamic>> _parseAyahs(String xml) {
  final out = <Map<String, dynamic>>[];
  int? currentSurah;
  for (final line in xml.split('\n')) {
    final suraMatch = _suraRe.firstMatch(line);
    if (suraMatch != null) {
      currentSurah = int.parse(suraMatch.group(1)!);
      continue;
    }
    final ayaMatch = _ayaRe.firstMatch(line);
    if (ayaMatch == null || currentSurah == null) continue;
    out.add({
      'surah': currentSurah,
      'ayah': int.parse(ayaMatch.group(1)!),
      'text': _unescape(ayaMatch.group(2)!),
    });
  }
  return out;
}

class _Start {
  final int index;
  final int sura;
  final int aya;
  const _Start(this.index, this.sura, this.aya);
}

List<_Start> _parseStarts(String xml, {required String tag}) {
  final re = RegExp(
    '<$tag index="(\\d+)" sura="(\\d+)" aya="(\\d+)"',
    unicode: true,
  );
  return [
    for (final m in re.allMatches(xml))
      _Start(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      ),
  ];
}

Map<int, int> _parseQuarterMap(String xml) {
  final re = RegExp(
    r'<quarter index="(\d+)" sura="(\d+)" aya="(\d+)"',
    unicode: true,
  );
  return {
    for (final m in re.allMatches(xml))
      _key(int.parse(m.group(2)!), int.parse(m.group(3)!)):
          int.parse(m.group(1)!),
  };
}

Map<int, String> _parseSajdaMap(String xml) {
  final re = RegExp(
    r'<sajda index="\d+" sura="(\d+)" aya="(\d+)" type="(\w+)"',
    unicode: true,
  );
  return {
    for (final m in re.allMatches(xml))
      _key(int.parse(m.group(1)!), int.parse(m.group(2)!)): m.group(3)!,
  };
}

int _key(int sura, int aya) => sura * 1000 + aya;

int _resolveStart(List<_Start> starts, int sura, int aya) {
  int current = 1;
  for (final s in starts) {
    final after = s.sura < sura || (s.sura == sura && s.aya <= aya);
    if (!after) return current;
    current = s.index;
  }
  return current;
}

String _unescape(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');
