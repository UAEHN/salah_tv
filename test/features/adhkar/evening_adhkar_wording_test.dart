import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard: the evening adhkar must use evening wording, not a copy of
/// the morning texts. The bug was every "evening" entry carrying the morning
/// Arabic text ("أصبحنا وأصبح الملك ...").
void main() {
  final adhkar =
      (jsonDecode(File('assets/adhkar/adhkar_text.json').readAsStringSync())
              as Map<String, dynamic>)['adhkar']
          as List;

  String joined(String categoryId) => adhkar
      .cast<Map<String, dynamic>>()
      .where((a) => a['categoryId'] == categoryId)
      .map((a) => a['text'] as String)
      .join('\n');

  test('morning keeps morning wording', () {
    expect(joined('morning'), contains('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ'));
  });

  test('evening uses evening wording, not the morning copy', () {
    final evening = joined('evening');
    expect(evening, contains('أَمْسَيْنَا وَأَمْسَى الْمُلْكُ'));
    expect(
      evening,
      isNot(contains('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ')),
      reason: 'evening must not reuse the morning "أصبحنا وأصبح الملك" text',
    );
  });
}
