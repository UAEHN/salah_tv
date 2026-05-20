import '../domain/entities/daily_verse.dart';

/// Curated 30-verse rotation for the "verse of the day" card. Each entry is
/// short enough for a card and chosen for its broad spiritual relevance.
/// Selection is `dayOfYear % length` so the same verse shows everywhere on
/// any given day. Adding entries grows the rotation without code changes.
const List<DailyVerse> kDailyVersesCatalog = [
  DailyVerse(
    surahNumber: 2,
    ayahNumber: 152,
    surahLabelKey: 'surahBaqarah',
    textAr: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
  ),
  DailyVerse(
    surahNumber: 2,
    ayahNumber: 286,
    surahLabelKey: 'surahBaqarah',
    textAr: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
  ),
  DailyVerse(
    surahNumber: 3,
    ayahNumber: 173,
    surahLabelKey: 'surahAlImran',
    textAr: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
  ),
  DailyVerse(
    surahNumber: 3,
    ayahNumber: 200,
    surahLabelKey: 'surahAlImran',
    textAr:
        'يَا أَيُّهَا الَّذِينَ آمَنُوا اصْبِرُوا وَصَابِرُوا وَرَابِطُوا وَاتَّقُوا اللَّهَ',
  ),
  DailyVerse(
    surahNumber: 6,
    ayahNumber: 162,
    surahLabelKey: 'surahAnam',
    textAr:
        'قُلْ إِنَّ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي لِلَّهِ رَبِّ الْعَالَمِينَ',
  ),
  DailyVerse(
    surahNumber: 7,
    ayahNumber: 156,
    surahLabelKey: 'surahAraf',
    textAr: 'وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ',
  ),
  DailyVerse(
    surahNumber: 9,
    ayahNumber: 51,
    surahLabelKey: 'surahTawbah',
    textAr: 'قُلْ لَنْ يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا',
  ),
  DailyVerse(
    surahNumber: 11,
    ayahNumber: 88,
    surahLabelKey: 'surahHud',
    textAr: 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ عَلَيْهِ تَوَكَّلْتُ',
  ),
  DailyVerse(
    surahNumber: 13,
    ayahNumber: 28,
    surahLabelKey: 'surahRad',
    textAr: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
  ),
  DailyVerse(
    surahNumber: 14,
    ayahNumber: 7,
    surahLabelKey: 'surahIbrahim',
    textAr: 'لَئِنْ شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
  ),
  DailyVerse(
    surahNumber: 16,
    ayahNumber: 97,
    surahLabelKey: 'surahNahl',
    textAr:
        'مَنْ عَمِلَ صَالِحًا مِنْ ذَكَرٍ أَوْ أُنْثَىٰ وَهُوَ مُؤْمِنٌ فَلَنُحْيِيَنَّهُ حَيَاةً طَيِّبَةً',
  ),
  DailyVerse(
    surahNumber: 17,
    ayahNumber: 80,
    surahLabelKey: 'surahIsra',
    textAr:
        'وَقُلْ رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ',
  ),
  DailyVerse(
    surahNumber: 20,
    ayahNumber: 25,
    surahLabelKey: 'surahTaha',
    textAr: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
  ),
  DailyVerse(
    surahNumber: 21,
    ayahNumber: 87,
    surahLabelKey: 'surahAnbiya',
    textAr:
        'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
  ),
  DailyVerse(
    surahNumber: 25,
    ayahNumber: 74,
    surahLabelKey: 'surahFurqan',
    textAr:
        'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ',
  ),
  DailyVerse(
    surahNumber: 28,
    ayahNumber: 24,
    surahLabelKey: 'surahQasas',
    textAr: 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
  ),
  DailyVerse(
    surahNumber: 29,
    ayahNumber: 69,
    surahLabelKey: 'surahAnkabut',
    textAr: 'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا',
  ),
  DailyVerse(
    surahNumber: 33,
    ayahNumber: 41,
    surahLabelKey: 'surahAhzab',
    textAr:
        'يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا',
  ),
  DailyVerse(
    surahNumber: 39,
    ayahNumber: 53,
    surahLabelKey: 'surahZumar',
    textAr: 'لَا تَقْنَطُوا مِنْ رَحْمَةِ اللَّهِ',
  ),
  DailyVerse(
    surahNumber: 40,
    ayahNumber: 60,
    surahLabelKey: 'surahGhafir',
    textAr: 'ادْعُونِي أَسْتَجِبْ لَكُمْ',
  ),
  DailyVerse(
    surahNumber: 42,
    ayahNumber: 11,
    surahLabelKey: 'surahShura',
    textAr: 'لَيْسَ كَمِثْلِهِ شَيْءٌ وَهُوَ السَّمِيعُ الْبَصِيرُ',
  ),
  DailyVerse(
    surahNumber: 49,
    ayahNumber: 13,
    surahLabelKey: 'surahHujurat',
    textAr: 'إِنَّ أَكْرَمَكُمْ عِنْدَ اللَّهِ أَتْقَاكُمْ',
  ),
  DailyVerse(
    surahNumber: 51,
    ayahNumber: 56,
    surahLabelKey: 'surahDhariyat',
    textAr: 'وَمَا خَلَقْتُ الْجِنَّ وَالْإِنْسَ إِلَّا لِيَعْبُدُونِ',
  ),
  DailyVerse(
    surahNumber: 55,
    ayahNumber: 13,
    surahLabelKey: 'surahRahman',
    textAr: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
  ),
  DailyVerse(
    surahNumber: 65,
    ayahNumber: 3,
    surahLabelKey: 'surahTalaq',
    textAr: 'وَمَنْ يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
  ),
  DailyVerse(
    surahNumber: 76,
    ayahNumber: 25,
    surahLabelKey: 'surahInsan',
    textAr: 'وَاذْكُرِ اسْمَ رَبِّكَ بُكْرَةً وَأَصِيلًا',
  ),
  DailyVerse(
    surahNumber: 93,
    ayahNumber: 5,
    surahLabelKey: 'surahDuha',
    textAr: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
  ),
  DailyVerse(
    surahNumber: 94,
    ayahNumber: 6,
    surahLabelKey: 'surahSharh',
    textAr: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
  ),
  DailyVerse(
    surahNumber: 103,
    ayahNumber: 3,
    surahLabelKey: 'surahAsr',
    textAr:
        'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ',
  ),
  DailyVerse(
    surahNumber: 112,
    ayahNumber: 1,
    surahLabelKey: 'surahIkhlas',
    textAr: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
  ),
];
