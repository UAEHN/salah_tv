/// Fixed metadata for the 30 ajzāʼ of the Madinah Mushaf. Each juz
/// starts on a well-known page; the opening phrase below is the
/// short tag used in classical recitation programmes (e.g. "سيقول"
/// for juz 2, "حم" for juz 26). Used by the Quran-tab juz index.
class JuzInfo {
  final int number;
  final int firstPage;
  final String openingPhrase;

  const JuzInfo({
    required this.number,
    required this.firstPage,
    required this.openingPhrase,
  });
}

const List<JuzInfo> kJuzList = [
  JuzInfo(number: 1, firstPage: 1, openingPhrase: 'الفاتحة'),
  JuzInfo(number: 2, firstPage: 22, openingPhrase: 'سَيَقُولُ'),
  JuzInfo(number: 3, firstPage: 42, openingPhrase: 'تِلْكَ الرُّسُلُ'),
  JuzInfo(number: 4, firstPage: 62, openingPhrase: 'لَنْ تَنَالُوا'),
  JuzInfo(number: 5, firstPage: 82, openingPhrase: 'وَالْمُحْصَنَاتُ'),
  JuzInfo(number: 6, firstPage: 102, openingPhrase: 'لَا يُحِبُّ ٱللَّهُ'),
  JuzInfo(number: 7, firstPage: 121, openingPhrase: 'وَإِذَا سَمِعُوا'),
  JuzInfo(number: 8, firstPage: 142, openingPhrase: 'وَلَوْ أَنَّنَا'),
  JuzInfo(number: 9, firstPage: 162, openingPhrase: 'قَالَ الْمَلَأُ'),
  JuzInfo(number: 10, firstPage: 182, openingPhrase: 'وَاعْلَمُوا'),
  JuzInfo(number: 11, firstPage: 201, openingPhrase: 'يَعْتَذِرُونَ'),
  JuzInfo(number: 12, firstPage: 222, openingPhrase: 'وَمَا مِنْ دَابَّةٍ'),
  JuzInfo(number: 13, firstPage: 242, openingPhrase: 'وَمَا أُبَرِّئُ'),
  JuzInfo(number: 14, firstPage: 262, openingPhrase: 'رُبَمَا'),
  JuzInfo(number: 15, firstPage: 282, openingPhrase: 'سُبْحَانَ الَّذِي'),
  JuzInfo(number: 16, firstPage: 302, openingPhrase: 'قَالَ أَلَمْ'),
  JuzInfo(number: 17, firstPage: 322, openingPhrase: 'اقْتَرَبَ'),
  JuzInfo(number: 18, firstPage: 342, openingPhrase: 'قَدْ أَفْلَحَ'),
  JuzInfo(number: 19, firstPage: 362, openingPhrase: 'وَقَالَ الَّذِينَ'),
  JuzInfo(number: 20, firstPage: 382, openingPhrase: 'أَمَّنْ خَلَقَ'),
  JuzInfo(number: 21, firstPage: 402, openingPhrase: 'اتْلُ مَا أُوحِيَ'),
  JuzInfo(number: 22, firstPage: 422, openingPhrase: 'وَمَنْ يَقْنُتْ'),
  JuzInfo(number: 23, firstPage: 442, openingPhrase: 'وَمَا لِيَ'),
  JuzInfo(number: 24, firstPage: 462, openingPhrase: 'فَمَنْ أَظْلَمُ'),
  JuzInfo(number: 25, firstPage: 482, openingPhrase: 'إِلَيْهِ يُرَدُّ'),
  JuzInfo(number: 26, firstPage: 502, openingPhrase: 'حم'),
  JuzInfo(number: 27, firstPage: 522, openingPhrase: 'قَالَ فَمَا خَطْبُكُمْ'),
  JuzInfo(number: 28, firstPage: 542, openingPhrase: 'قَدْ سَمِعَ'),
  JuzInfo(number: 29, firstPage: 562, openingPhrase: 'تَبَارَكَ الَّذِي'),
  JuzInfo(number: 30, firstPage: 582, openingPhrase: 'عَمَّ'),
];
