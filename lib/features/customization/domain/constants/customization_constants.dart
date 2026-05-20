/// Mobile-only constants for the customization feature.
/// TV palette/font surfaces remain on the legacy `kThemePalettes` map.
library;

/// Default theme key when nothing is selected (matches `AppSettings`).
const String kDefaultThemeKey = 'green';

/// Default font family when nothing is selected (matches `AppSettings`).
const String kDefaultFontFamily = 'Kufi';

/// Sample text rendered inside font preview cards. Bilingual: Arabic shahada
/// + a short Latin sample so both Arabic and Latin scripts are visible.
const String kFontSampleArabic = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
const String kFontSampleLatin = 'In the name of Allah';
