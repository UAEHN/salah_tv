// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ghasaq';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get localeComma => ',';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonError => 'Error';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaveChanges => 'Save changes';

  @override
  String get navSettings => 'Settings';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navAdhkar => 'Adhkar';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navTasbih => 'Tasbih';

  @override
  String get adhkarNotAvailableOnTv => 'Adhkar is not available on TV devices';

  @override
  String adhkarCompletedCategory(Object categoryName) {
    return 'You have completed $categoryName';
  }

  @override
  String get adhkarMayAllahAccept => 'May Allah accept from you';

  @override
  String get adhkarBackToCategories => 'Back to categories';

  @override
  String adhkarCountLabel(int count) {
    return '$count adhkar';
  }

  @override
  String get adhkarMorningSession => 'Morning adhkar';

  @override
  String get adhkarEveningSession => 'Evening adhkar';

  @override
  String get tasbihEntrySummary => 'Tap to start your daily tasbih';

  @override
  String get tasbihPhraseSubhanAllah => 'Subhan Allah';

  @override
  String get tasbihPhraseAlhamdulillah => 'Alhamdulillah';

  @override
  String get tasbihPhraseAllahuAkbar => 'Allahu Akbar';

  @override
  String get tasbihPhraseLaIlahaIllallah => 'La ilaha illa Allah';

  @override
  String get tasbihCompletedMessage => 'Completed';

  @override
  String get tasbihSwipeHint => 'Swipe to switch phrase';

  @override
  String get tasbihResetTooltip => 'Reset counter';

  @override
  String get duaAfterAdhanTitle => 'Supplication after Adhan';

  @override
  String get duaAfterAdhanText =>
      'O Allah, Lord of this perfect call and established prayer, grant Muhammad Al-Wasilah and virtue, and raise him to the praised station You have promised him.';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get nextPrayerLabel => 'Time remaining for Adhan';

  @override
  String get nextPrayerActiveLabel => 'Next prayer';

  @override
  String countdownNextPrayer(Object prayerName) {
    return 'Next prayer in $prayerName';
  }

  @override
  String countdownToIqama(Object prayerName) {
    return 'Iqama for $prayerName in';
  }

  @override
  String iqamaAfterPrayer(Object prayerName) {
    return 'Iqama for $prayerName in';
  }

  @override
  String get ongoingNow => 'In progress';

  @override
  String get adhanNowTitle => 'It is now time for';

  @override
  String adhanPrayerTitle(Object prayerName) {
    return 'Adhan for $prayerName';
  }

  @override
  String get skipAdhanHint => 'Press OK to skip Adhan';

  @override
  String get iqamaNowTitle => 'Prayer time';

  @override
  String get iqamaLabel => 'Iqama';

  @override
  String get noPrayerDataToday => 'No prayer data for today';

  @override
  String get noPrayerDataForDate => 'No prayer data for this date';

  @override
  String get checkCsvInSettings => 'Check CSV data in settings';

  @override
  String get pressOkForSettings => 'Press OK for settings';

  @override
  String get backToToday => 'Back to today';

  @override
  String get notificationReminderTitle => 'Reminder';

  @override
  String get notificationIqamaTitle => 'Iqama';

  @override
  String notificationAdhanBody(Object prayerName) {
    return 'It is time for $prayerName';
  }

  @override
  String notificationPreAdhanBody(Object prayerName, Object minutes) {
    return '$prayerName in $minutes minutes';
  }

  @override
  String notificationPreIqamaBody(Object prayerName, Object minutes) {
    return 'Iqama for $prayerName in $minutes minutes';
  }

  @override
  String notificationIqamaBody(Object prayerName) {
    return 'It is time for Iqama of $prayerName';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTimeFormat => 'Time Format';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsOther => 'Other';

  @override
  String get settings24HourFormat => '24-Hour Format';

  @override
  String get settings24HourEnabled => '24-hour system';

  @override
  String get settings12HourEnabled => '12-hour system';

  @override
  String get settings24HourLabel => '24 hours';

  @override
  String get settings12HourLabel => '12 hours';

  @override
  String get settingsCustomizeAppearance => 'Customize Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLightMode => 'Light Mode';

  @override
  String get settingsDarkModeLabel => 'Night mode';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsLocationSection => 'Location';

  @override
  String get settingsCountryAndCity => 'Country and city';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationSettings => 'Notification settings';

  @override
  String get settingsCalculationSection => 'Calculation';

  @override
  String get settingsCalculationMethodLabel => 'Calculation method';

  @override
  String get settingsMadhabLabel => 'Madhab';

  @override
  String get settingsAdjustPrayerTimes => 'Adjust adhan and iqama times';

  @override
  String get settingsGeneralSettings => 'General settings';

  @override
  String get settingsPrayerAlerts => 'Prayer alerts';

  @override
  String get settingsAdhanSoundLabel => 'Adhan sound';

  @override
  String get settingsPreAdhanReminder => 'Reminder before adhan';

  @override
  String get settingsAdhanAlert => 'Adhan alert';

  @override
  String get settingsPreIqamaReminder => 'Reminder before iqama';

  @override
  String get settingsIqamaAlert => 'Iqama alert';

  @override
  String get settingsPreAdhanDuration => 'Reminder duration before adhan';

  @override
  String get settingsPreIqamaDuration => 'Reminder duration before iqama';

  @override
  String settingsBeforeMinutes(Object minutes) {
    return '$minutes minutes before';
  }

  @override
  String settingsDurationMinutes(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get settingsAdjustTimes => 'Adjust times';

  @override
  String get settingsAdjustAdhanTimeTitle => 'Adjust adhan time';

  @override
  String get settingsAdjustAdhanTimeSubtitle =>
      'Advance or delay adhan (-30 to +30 min)';

  @override
  String get settingsIqamaDelayTitle => 'Iqama delay';

  @override
  String get settingsIqamaDelaySubtitle => 'Minutes after adhan (0 to 60 min)';

  @override
  String get settingsMinuteShort => 'm';

  @override
  String get settingsMinuteUnit => 'minute';

  @override
  String get settingsMadhabAffectsAsrNote =>
      'Affects Asr time for calculated (GPS) times only';

  @override
  String get settingsHanafiAsrLaterNote =>
      'Hanafi madhab shifts Asr slightly later';

  @override
  String get madhabShafi => 'Shafi';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get madhabShafiFamily => 'Shafi / Maliki / Hanbali';

  @override
  String get settingsChooseAdhanSound => 'Choose adhan sound';

  @override
  String get settingsDetectingLocation => 'Detecting location...';

  @override
  String get settingsDetectMyLocation => 'Detect my location automatically';

  @override
  String get settingsNoMatchingCountries => 'No matching countries';

  @override
  String get settingsNoMatchingCities => 'No matching cities';

  @override
  String get settingsSelectCountry => 'Select country';

  @override
  String get settingsSelectCity => 'Select city';

  @override
  String get settingsSearchCountry => 'Search for a country';

  @override
  String get settingsSearchCity => 'Search for a city';

  @override
  String get settingsMethodAffectsGpsOnly =>
      'Affects calculated (GPS) times only';

  @override
  String get settingsNotificationsEnabled => 'Notifications enabled';

  @override
  String get settingsNotificationsDisabled => 'Notifications disabled';

  @override
  String get settingsCategoryLocation => 'Location';

  @override
  String get settingsCategoryLocationSubtitle => 'Country and city';

  @override
  String get settingsCategoryQuran => 'Quran';

  @override
  String get settingsCategoryQuranSubtitle => 'Background Quran streaming';

  @override
  String get settingsCategoryAdhan => 'Adhan';

  @override
  String get settingsCategoryAdhanSubtitle => 'Adhan sound and auto playback';

  @override
  String get settingsCategoryAdhanOffsets => 'Adhan offsets';

  @override
  String get settingsCategoryAdhanOffsetsSubtitle => 'Adjust adhan times';

  @override
  String get settingsCategoryIqama => 'Iqama offsets';

  @override
  String get settingsCategoryIqamaSubtitle => 'Iqama delay after adhan';

  @override
  String get settingsCategoryAppearance => 'Appearance';

  @override
  String get settingsCategoryAppearanceSubtitle => 'Font, colors, and layout';

  @override
  String get settingsCategoryAdhkar => 'Adhkar';

  @override
  String get settingsCategoryAdhkarSubtitle => 'Morning and evening adhkar';

  @override
  String get settingsFont => 'Font';

  @override
  String get settingsThemeColor => 'Theme color';

  @override
  String get settingsLayoutDesign => 'Layout design';

  @override
  String get settingsClockType => 'Clock type';

  @override
  String get layoutModern => 'Modern';

  @override
  String get layoutClassic => 'Classic';

  @override
  String get clockDigital => 'Digital';

  @override
  String get clockAnalog => 'Analog';

  @override
  String get fontCairo => 'Cairo';

  @override
  String get fontBeiruti => 'Beiruti';

  @override
  String get fontKufi => 'Kufi';

  @override
  String get fontRubik => 'Rubik';

  @override
  String get fontInter => 'Inter';

  @override
  String get themeGreen => 'Emerald';

  @override
  String get themeTeal => 'Turquoise';

  @override
  String get themeGold => 'Gold';

  @override
  String get themeBlue => 'Blue';

  @override
  String get themePurple => 'Purple';

  @override
  String get settingsAutoPlayAdhan => 'Play adhan automatically:';

  @override
  String get settingsChangeAdhan => 'Change adhan';

  @override
  String get settingsQuranInBackground => 'Play Quran in background:';

  @override
  String get settingsNoReciterSelected => 'No reciter selected';

  @override
  String get settingsChangeReciter => 'Change reciter';

  @override
  String get settingsInternetRequiredForQuran =>
      'Internet is required to load reciters and play Quran.';

  @override
  String get settingsMorningEveningAdhkar => 'Morning and evening adhkar:';

  @override
  String get settingsAdhkarScheduleNote =>
      'Morning adhkar appears after Fajr until 10:00 AM. Evening adhkar appears after Asr and ends 5 minutes before Maghrib adhan. It appears once daily and pauses during adhan and iqama.';

  @override
  String get settingsNoCitySelected => 'No city selected';

  @override
  String get settingsChangeCity => 'Change city';

  @override
  String get settingsChangeCountry => 'Change country';

  @override
  String get settingsCloseApp => 'Close app';

  @override
  String get settingsSelectReciter => 'Choose reciter';

  @override
  String get settingsFailedToLoadReciters =>
      'Failed to load reciters.\nCheck your internet connection.';

  @override
  String get settingsLoadingReciters => 'Loading reciters...';

  @override
  String get adhanSound1 => 'Adhan 1';

  @override
  String get adhanSound2 => 'Adhan 2';

  @override
  String get adhanSoundAliMulla => 'Shaykh Ali Mulla';

  @override
  String get adhanSoundAbdulbasit => 'Shaykh Abdulbasit Abdulsamad';

  @override
  String get adhanSoundAqsa => 'Al-Aqsa Mosque Adhan';

  @override
  String get qiblaPermissionDeniedTitle => 'Location denied';

  @override
  String get qiblaPermissionDeniedSubtitle =>
      'Please allow location access from settings';

  @override
  String get qiblaGpsDisabledTitle => 'GPS is disabled';

  @override
  String get qiblaGpsDisabledSubtitle => 'Please enable location service';

  @override
  String get qiblaNotAvailableOnTv => 'Qibla is not available on TV devices';

  @override
  String get qiblaAlignedStatus => 'You are facing the Qibla';

  @override
  String get qiblaFindStatus => 'Turn toward the Qibla';

  @override
  String get qiblaAlignedSub => 'ALIGNED WITH KAABA';

  @override
  String get qiblaFindSub => 'FIND THE KAABA';

  @override
  String get qiblaDistanceToKaaba => 'Distance to Kaaba';

  @override
  String get qiblaDeviation => 'Deviation';

  @override
  String get unitKm => 'km';

  @override
  String get unitDegree => 'degree';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get gregorianMonthJanuary => 'January';

  @override
  String get gregorianMonthFebruary => 'February';

  @override
  String get gregorianMonthMarch => 'March';

  @override
  String get gregorianMonthApril => 'April';

  @override
  String get gregorianMonthMay => 'May';

  @override
  String get gregorianMonthJune => 'June';

  @override
  String get gregorianMonthJuly => 'July';

  @override
  String get gregorianMonthAugust => 'August';

  @override
  String get gregorianMonthSeptember => 'September';

  @override
  String get gregorianMonthOctober => 'October';

  @override
  String get gregorianMonthNovember => 'November';

  @override
  String get gregorianMonthDecember => 'December';

  @override
  String get hijriMonthMuharram => 'Muharram';

  @override
  String get hijriMonthSafar => 'Safar';

  @override
  String get hijriMonthRabiAlAwwal => 'Rabi Al-Awwal';

  @override
  String get hijriMonthRabiAlThani => 'Rabi Al-Thani';

  @override
  String get hijriMonthJumadaAlAwwal => 'Jumada Al-Awwal';

  @override
  String get hijriMonthJumadaAlAkhirah => 'Jumada Al-Akhirah';

  @override
  String get hijriMonthRajab => 'Rajab';

  @override
  String get hijriMonthShaban => 'Sha\'ban';

  @override
  String get hijriMonthRamadan => 'Ramadan';

  @override
  String get hijriMonthShawwal => 'Shawwal';

  @override
  String get hijriMonthDhuAlQadah => 'Dhu Al-Qadah';

  @override
  String get hijriMonthDhuAlHijjah => 'Dhu Al-Hijjah';

  @override
  String get hijriYearSuffix => 'AH';

  @override
  String get gregorianYearSuffix => 'AD';

  @override
  String get calcMethodMuslimWorldLeague => 'Muslim World League';

  @override
  String get calcMethodEgyptian => 'Egyptian General Authority of Survey';

  @override
  String get calcMethodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get calcMethodUmmAlQura => 'Umm Al-Qura';

  @override
  String get calcMethodDubai => 'Dubai';

  @override
  String get calcMethodQatar => 'Qatar';

  @override
  String get calcMethodKuwait => 'Kuwait';

  @override
  String get calcMethodMorocco => 'Morocco';

  @override
  String get calcMethodSingapore => 'Singapore';

  @override
  String get calcMethodTehran => 'Tehran';

  @override
  String get calcMethodTurkiye => 'Turkiye (Diyanet)';

  @override
  String get calcMethodNorthAmerica => 'North America (ISNA)';

  @override
  String get calcMethodMoonsightingCommittee => 'Moonsighting Committee';

  @override
  String get splashVerseStart =>
      'أَقِمِ ٱلصَّلَوٰةَ لِدُلُوكِ ٱلشَّمْسِ إِلَىٰ ';

  @override
  String get splashVerseHighlight => 'غَسَقِ';

  @override
  String get splashVerseEnd => ' ٱلَّيْلِ';

  @override
  String get splashVerseReference => 'الإسراء: ٧٨';

  @override
  String get fontPreviewSample => 'Abcd Abcd';
}
