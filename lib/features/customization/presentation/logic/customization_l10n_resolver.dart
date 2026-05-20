import 'package:ghasaq/l10n/app_localizations.dart';

/// Maps a `labelKey` (carried by domain entities) to its localized string.
/// Keeps switch-statements out of widgets and lets us add palettes/fonts
/// without touching presentation files.
String resolveThemeLabel(AppLocalizations l, String labelKey) {
  switch (labelKey) {
    case 'themeGreen':
      return l.themeGreen;
    case 'themeTeal':
      return l.themeTeal;
    case 'themeGold':
      return l.themeGold;
    case 'themeBlue':
      return l.themeBlue;
    case 'themePurple':
      return l.themePurple;
    case 'themeCoral':
      return l.themeCoral;
    case 'themeAzure':
      return l.themeAzure;
    default:
      return labelKey;
  }
}

String resolveFontLabel(AppLocalizations l, String labelKey) {
  switch (labelKey) {
    case 'fontKufi':
      return l.fontKufi;
    case 'fontCairo':
      return l.fontCairo;
    case 'fontBeiruti':
      return l.fontBeiruti;
    case 'fontRubik':
      return l.fontRubik;
    case 'fontInter':
      return l.fontInter;
    default:
      return labelKey;
  }
}

String resolveFontHint(AppLocalizations l, String hintKey) {
  if (hintKey.isEmpty) return '';
  switch (hintKey) {
    case 'fontHintKufi':
      return l.fontHintKufi;
    case 'fontHintCairo':
      return l.fontHintCairo;
    case 'fontHintBeiruti':
      return l.fontHintBeiruti;
    case 'fontHintRubik':
      return l.fontHintRubik;
    case 'fontHintInter':
      return l.fontHintInter;
    default:
      return '';
  }
}

String resolveErrorMessage(AppLocalizations l, String key) {
  switch (key) {
    case 'themePickerLoadError':
      return l.themePickerLoadError;
    case 'fontPickerLoadError':
      return l.fontPickerLoadError;
    default:
      return l.commonError;
  }
}

/// Map a stored theme color key (`AppSettings.themeColorKey`) to its
/// localization label key. Returns `'themeGreen'` for unknown keys to mirror
/// the `getMobileThemePalette` fallback.
String themeKeyToLabelKey(String themeKey) {
  const map = <String, String>{
    'green': 'themeGreen',
    'teal': 'themeTeal',
    'gold': 'themeGold',
    'blue': 'themeBlue',
    'purple': 'themePurple',
    'desert_dawn': 'themeCoral',
    'paradise_sea': 'themeAzure',
  };
  return map[themeKey] ?? 'themeGreen';
}

/// Map a stored font family (`AppSettings.fontFamily`) to its localization
/// label key.
String fontFamilyToLabelKey(String fontFamily) {
  const map = <String, String>{
    'Kufi': 'fontKufi',
    'Cairo': 'fontCairo',
    'Beiruti': 'fontBeiruti',
    'Rubik': 'fontRubik',
    'Inter': 'fontInter',
  };
  return map[fontFamily] ?? 'fontKufi';
}
