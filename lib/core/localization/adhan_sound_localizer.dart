import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

String localizedAdhanSoundLabel(BuildContext context, String soundKey) {
  final l = AppLocalizations.of(context);
  return localizedAdhanSoundLabelFromLocalizations(l, soundKey);
}

String localizedAdhanSoundLabelFromLocalizations(
  AppLocalizations l,
  String soundKey,
) {
  switch (soundKey) {
    case 'default':
      return l.adhanSound1;
    case 'adhan2':
      return l.adhanSound2;
    case 'ali_mulla':
      return l.adhanSoundAliMulla;
    case 'abdulbasit':
      return l.adhanSoundAbdulbasit;
    case 'aqsa':
      return l.adhanSoundAqsa;
    default:
      return l.adhanSound1;
  }
}
