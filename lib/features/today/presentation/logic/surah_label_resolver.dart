import 'package:ghasaq/l10n/app_localizations.dart';

/// Resolves the surah label key carried on a `DailyVerse` to the localized
/// surah name. Returns the numeric label as a fallback so the UI can still
/// show *something* if a verse references a surah we haven't translated yet.
String resolveSurahLabel(
  AppLocalizations l,
  String surahLabelKey, {
  required int surahNumber,
}) {
  switch (surahLabelKey) {
    case 'surahBaqarah':
      return l.surahBaqarah;
    case 'surahAlImran':
      return l.surahAlImran;
    case 'surahAnam':
      return l.surahAnam;
    case 'surahAraf':
      return l.surahAraf;
    case 'surahTawbah':
      return l.surahTawbah;
    case 'surahHud':
      return l.surahHud;
    case 'surahRad':
      return l.surahRad;
    case 'surahIbrahim':
      return l.surahIbrahim;
    case 'surahNahl':
      return l.surahNahl;
    case 'surahIsra':
      return l.surahIsra;
    case 'surahTaha':
      return l.surahTaha;
    case 'surahAnbiya':
      return l.surahAnbiya;
    case 'surahFurqan':
      return l.surahFurqan;
    case 'surahQasas':
      return l.surahQasas;
    case 'surahAnkabut':
      return l.surahAnkabut;
    case 'surahAhzab':
      return l.surahAhzab;
    case 'surahZumar':
      return l.surahZumar;
    case 'surahGhafir':
      return l.surahGhafir;
    case 'surahShura':
      return l.surahShura;
    case 'surahHujurat':
      return l.surahHujurat;
    case 'surahDhariyat':
      return l.surahDhariyat;
    case 'surahRahman':
      return l.surahRahman;
    case 'surahTalaq':
      return l.surahTalaq;
    case 'surahInsan':
      return l.surahInsan;
    case 'surahDuha':
      return l.surahDuha;
    case 'surahSharh':
      return l.surahSharh;
    case 'surahAsr':
      return l.surahAsr;
    case 'surahIkhlas':
      return l.surahIkhlas;
    default:
      return '$surahNumber';
  }
}
