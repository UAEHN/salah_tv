import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'غسق'**
  String get appTitle;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @localeComma.
  ///
  /// In ar, this message translates to:
  /// **'،'**
  String get localeComma;

  /// No description provided for @commonEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get commonEnabled;

  /// No description provided for @commonDisabled.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get commonDisabled;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get commonError;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonSaveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get commonSaveChanges;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @navQibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get navQibla;

  /// No description provided for @navAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get navAdhkar;

  /// No description provided for @navPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة'**
  String get navPrayer;

  /// No description provided for @navTasbih.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get navTasbih;

  /// No description provided for @adhkarNotAvailableOnTv.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار غير متوفرة على أجهزة التلفاز'**
  String get adhkarNotAvailableOnTv;

  /// No description provided for @adhkarCompletedCategory.
  ///
  /// In ar, this message translates to:
  /// **'أنهيت {categoryName}'**
  String adhkarCompletedCategory(Object categoryName);

  /// No description provided for @adhkarMayAllahAccept.
  ///
  /// In ar, this message translates to:
  /// **'تقبل الله منك'**
  String get adhkarMayAllahAccept;

  /// No description provided for @adhkarBackToCategories.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى التصنيفات'**
  String get adhkarBackToCategories;

  /// No description provided for @adhkarCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} ذكر'**
  String adhkarCountLabel(int count);

  /// No description provided for @adhkarMorningSession.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get adhkarMorningSession;

  /// No description provided for @adhkarEveningSession.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get adhkarEveningSession;

  /// No description provided for @tasbihEntrySummary.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسبيح اليومي'**
  String get tasbihEntrySummary;

  /// No description provided for @tasbihPhraseSubhanAllah.
  ///
  /// In ar, this message translates to:
  /// **'سبحان الله'**
  String get tasbihPhraseSubhanAllah;

  /// No description provided for @tasbihPhraseAlhamdulillah.
  ///
  /// In ar, this message translates to:
  /// **'الحمد لله'**
  String get tasbihPhraseAlhamdulillah;

  /// No description provided for @tasbihPhraseAllahuAkbar.
  ///
  /// In ar, this message translates to:
  /// **'الله أكبر'**
  String get tasbihPhraseAllahuAkbar;

  /// No description provided for @tasbihPhraseLaIlahaIllallah.
  ///
  /// In ar, this message translates to:
  /// **'لا إله إلا الله'**
  String get tasbihPhraseLaIlahaIllallah;

  /// No description provided for @tasbihCompletedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم الإنجاز'**
  String get tasbihCompletedMessage;

  /// No description provided for @tasbihSwipeHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب للتبديل بين الأذكار'**
  String get tasbihSwipeHint;

  /// No description provided for @tasbihResetTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إعادة العداد'**
  String get tasbihResetTooltip;

  /// No description provided for @duaAfterAdhanTitle.
  ///
  /// In ar, this message translates to:
  /// **'دعاء بعد الأذان'**
  String get duaAfterAdhanTitle;

  /// No description provided for @duaAfterAdhanText.
  ///
  /// In ar, this message translates to:
  /// **'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ.'**
  String get duaAfterAdhanText;

  /// No description provided for @prayerFajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get prayerIsha;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي على أذان'**
  String get nextPrayerLabel;

  /// No description provided for @nextPrayerActiveLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayerActiveLabel;

  /// No description provided for @countdownNextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'باقي على صلاة {prayerName}'**
  String countdownNextPrayer(Object prayerName);

  /// No description provided for @countdownToIqama.
  ///
  /// In ar, this message translates to:
  /// **'باقي على إقامة {prayerName}'**
  String countdownToIqama(Object prayerName);

  /// No description provided for @iqamaAfterPrayer.
  ///
  /// In ar, this message translates to:
  /// **'إقامة صلاة {prayerName} بعد'**
  String iqamaAfterPrayer(Object prayerName);

  /// No description provided for @ongoingNow.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الآن'**
  String get ongoingNow;

  /// No description provided for @adhanNowTitle.
  ///
  /// In ar, this message translates to:
  /// **'حان الآن موعد'**
  String get adhanNowTitle;

  /// No description provided for @adhanPrayerTitle.
  ///
  /// In ar, this message translates to:
  /// **'أذان {prayerName}'**
  String adhanPrayerTitle(Object prayerName);

  /// No description provided for @skipAdhanHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط OK لتخطي الأذان'**
  String get skipAdhanHint;

  /// No description provided for @iqamaNowTitle.
  ///
  /// In ar, this message translates to:
  /// **'حان موعد صلاة'**
  String get iqamaNowTitle;

  /// No description provided for @iqamaLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإقامة'**
  String get iqamaLabel;

  /// No description provided for @noPrayerDataToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات لهذا اليوم'**
  String get noPrayerDataToday;

  /// No description provided for @noPrayerDataForDate.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات لهذا التاريخ'**
  String get noPrayerDataForDate;

  /// No description provided for @checkCsvInSettings.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من ملف CSV في الإعدادات'**
  String get checkCsvInSettings;

  /// No description provided for @pressOkForSettings.
  ///
  /// In ar, this message translates to:
  /// **'اضغط OK للإعدادات'**
  String get pressOkForSettings;

  /// No description provided for @backToToday.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى اليوم'**
  String get backToToday;

  /// No description provided for @notificationReminderTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير'**
  String get notificationReminderTitle;

  /// No description provided for @notificationIqamaTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإقامة'**
  String get notificationIqamaTitle;

  /// No description provided for @notificationAdhanBody.
  ///
  /// In ar, this message translates to:
  /// **'حان وقت {prayerName}'**
  String notificationAdhanBody(Object prayerName);

  /// No description provided for @notificationPreAdhanBody.
  ///
  /// In ar, this message translates to:
  /// **'{prayerName} بعد {minutes} دقيقة'**
  String notificationPreAdhanBody(Object prayerName, Object minutes);

  /// No description provided for @notificationPreIqamaBody.
  ///
  /// In ar, this message translates to:
  /// **'إقامة {prayerName} بعد {minutes} دقيقة'**
  String notificationPreIqamaBody(Object prayerName, Object minutes);

  /// No description provided for @notificationIqamaBody.
  ///
  /// In ar, this message translates to:
  /// **'حان وقت إقامة {prayerName}'**
  String notificationIqamaBody(Object prayerName);

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsTimeFormat.
  ///
  /// In ar, this message translates to:
  /// **'صيغة الوقت'**
  String get settingsTimeFormat;

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @settingsOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get settingsOther;

  /// No description provided for @settings24HourFormat.
  ///
  /// In ar, this message translates to:
  /// **'صيغة 24 ساعة'**
  String get settings24HourFormat;

  /// No description provided for @settings24HourEnabled.
  ///
  /// In ar, this message translates to:
  /// **'نظام 24 ساعة'**
  String get settings24HourEnabled;

  /// No description provided for @settings12HourEnabled.
  ///
  /// In ar, this message translates to:
  /// **'نظام 12 ساعة'**
  String get settings12HourEnabled;

  /// No description provided for @settings24HourLabel.
  ///
  /// In ar, this message translates to:
  /// **'24 ساعة'**
  String get settings24HourLabel;

  /// No description provided for @settings12HourLabel.
  ///
  /// In ar, this message translates to:
  /// **'12 ساعة'**
  String get settings12HourLabel;

  /// No description provided for @settingsCustomizeAppearance.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص المظهر'**
  String get settingsCustomizeAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get settingsDarkMode;

  /// No description provided for @settingsLightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get settingsLightMode;

  /// No description provided for @settingsDarkModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get settingsDarkModeLabel;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsLocationSection.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get settingsLocationSection;

  /// No description provided for @settingsCountryAndCity.
  ///
  /// In ar, this message translates to:
  /// **'الدولة والمدينة'**
  String get settingsCountryAndCity;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التنبيهات'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsCalculationSection.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settingsCalculationSection;

  /// No description provided for @settingsCalculationMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get settingsCalculationMethodLabel;

  /// No description provided for @settingsMadhabLabel.
  ///
  /// In ar, this message translates to:
  /// **'المذهب الفقهي'**
  String get settingsMadhabLabel;

  /// No description provided for @settingsAdjustPrayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'تعديل أوقات الأذان والإقامة'**
  String get settingsAdjustPrayerTimes;

  /// No description provided for @settingsGeneralSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات عامة'**
  String get settingsGeneralSettings;

  /// No description provided for @settingsPrayerAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الصلوات'**
  String get settingsPrayerAlerts;

  /// No description provided for @settingsAdhanSoundLabel.
  ///
  /// In ar, this message translates to:
  /// **'صوت الأذان'**
  String get settingsAdhanSoundLabel;

  /// No description provided for @settingsPreAdhanReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير قبل الأذان'**
  String get settingsPreAdhanReminder;

  /// No description provided for @settingsAdhanAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه الأذان'**
  String get settingsAdhanAlert;

  /// No description provided for @settingsPreIqamaReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير قبل الإقامة'**
  String get settingsPreIqamaReminder;

  /// No description provided for @settingsIqamaAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه الإقامة'**
  String get settingsIqamaAlert;

  /// No description provided for @settingsPreAdhanDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة التذكير قبل الأذان'**
  String get settingsPreAdhanDuration;

  /// No description provided for @settingsPreIqamaDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة التذكير قبل الإقامة'**
  String get settingsPreIqamaDuration;

  /// No description provided for @settingsBeforeMinutes.
  ///
  /// In ar, this message translates to:
  /// **'قبل {minutes} دقيقة'**
  String settingsBeforeMinutes(Object minutes);

  /// No description provided for @settingsDurationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String settingsDurationMinutes(Object minutes);

  /// No description provided for @settingsAdjustTimes.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الأوقات'**
  String get settingsAdjustTimes;

  /// No description provided for @settingsAdjustAdhanTimeTitle.
  ///
  /// In ar, this message translates to:
  /// **'ضبط وقت الأذان'**
  String get settingsAdjustAdhanTimeTitle;

  /// No description provided for @settingsAdjustAdhanTimeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تقديم أو تأخير الأذان (−30 إلى +30 دقيقة)'**
  String get settingsAdjustAdhanTimeSubtitle;

  /// No description provided for @settingsIqamaDelayTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأخير الإقامة'**
  String get settingsIqamaDelayTitle;

  /// No description provided for @settingsIqamaDelaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عدد الدقائق بعد الأذان (0 إلى 60 دقيقة)'**
  String get settingsIqamaDelaySubtitle;

  /// No description provided for @settingsMinuteShort.
  ///
  /// In ar, this message translates to:
  /// **'د'**
  String get settingsMinuteShort;

  /// No description provided for @settingsMinuteUnit.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get settingsMinuteUnit;

  /// No description provided for @settingsMadhabAffectsAsrNote.
  ///
  /// In ar, this message translates to:
  /// **'يؤثر على وقت العصر في الأوقات المحسوبة (GPS) فقط'**
  String get settingsMadhabAffectsAsrNote;

  /// No description provided for @settingsHanafiAsrLaterNote.
  ///
  /// In ar, this message translates to:
  /// **'المذهب الحنفي يُؤخّر وقت العصر قليلاً'**
  String get settingsHanafiAsrLaterNote;

  /// No description provided for @madhabShafi.
  ///
  /// In ar, this message translates to:
  /// **'الشافعي'**
  String get madhabShafi;

  /// No description provided for @madhabHanafi.
  ///
  /// In ar, this message translates to:
  /// **'الحنفي'**
  String get madhabHanafi;

  /// No description provided for @madhabShafiFamily.
  ///
  /// In ar, this message translates to:
  /// **'الشافعي / المالكي / الحنبلي'**
  String get madhabShafiFamily;

  /// No description provided for @settingsChooseAdhanSound.
  ///
  /// In ar, this message translates to:
  /// **'اختر صوت الأذان'**
  String get settingsChooseAdhanSound;

  /// No description provided for @settingsDetectingLocation.
  ///
  /// In ar, this message translates to:
  /// **'جارِ تحديد الموقع...'**
  String get settingsDetectingLocation;

  /// No description provided for @settingsDetectMyLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديد موقعي تلقائياً'**
  String get settingsDetectMyLocation;

  /// No description provided for @settingsNoMatchingCountries.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دول مطابقة'**
  String get settingsNoMatchingCountries;

  /// No description provided for @settingsNoMatchingCities.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مدن مطابقة'**
  String get settingsNoMatchingCities;

  /// No description provided for @settingsSelectCountry.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة'**
  String get settingsSelectCountry;

  /// No description provided for @settingsSelectCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر المدينة'**
  String get settingsSelectCity;

  /// No description provided for @settingsSearchCountry.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن دولة'**
  String get settingsSearchCountry;

  /// No description provided for @settingsSearchCity.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مدينة'**
  String get settingsSearchCity;

  /// No description provided for @settingsMethodAffectsGpsOnly.
  ///
  /// In ar, this message translates to:
  /// **'تؤثر على الأوقات المحسوبة (GPS) فقط'**
  String get settingsMethodAffectsGpsOnly;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مفعّلة'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsDisabled.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات معطّلة'**
  String get settingsNotificationsDisabled;

  /// No description provided for @settingsCategoryLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get settingsCategoryLocation;

  /// No description provided for @settingsCategoryLocationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الدولة والمدينة'**
  String get settingsCategoryLocationSubtitle;

  /// No description provided for @settingsCategoryQuran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get settingsCategoryQuran;

  /// No description provided for @settingsCategoryQuranSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بث القرآن في الخلفية'**
  String get settingsCategoryQuranSubtitle;

  /// No description provided for @settingsCategoryAdhan.
  ///
  /// In ar, this message translates to:
  /// **'الأذان'**
  String get settingsCategoryAdhan;

  /// No description provided for @settingsCategoryAdhanSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'صوت الأذان والتشغيل التلقائي'**
  String get settingsCategoryAdhanSubtitle;

  /// No description provided for @settingsCategoryAdhanOffsets.
  ///
  /// In ar, this message translates to:
  /// **'تعديل أوقات الأذان'**
  String get settingsCategoryAdhanOffsets;

  /// No description provided for @settingsCategoryAdhanOffsetsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ضبط أوقات الأذان'**
  String get settingsCategoryAdhanOffsetsSubtitle;

  /// No description provided for @settingsCategoryIqama.
  ///
  /// In ar, this message translates to:
  /// **'تعديل أوقات الإقامة'**
  String get settingsCategoryIqama;

  /// No description provided for @settingsCategoryIqamaSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الإقامة بعد الأذان'**
  String get settingsCategoryIqamaSubtitle;

  /// No description provided for @settingsCategoryAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsCategoryAppearance;

  /// No description provided for @settingsCategoryAppearanceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الخط والألوان والتصميم'**
  String get settingsCategoryAppearanceSubtitle;

  /// No description provided for @settingsCategoryAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get settingsCategoryAdhkar;

  /// No description provided for @settingsCategoryAdhkarSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح والمساء'**
  String get settingsCategoryAdhkarSubtitle;

  /// No description provided for @settingsFont.
  ///
  /// In ar, this message translates to:
  /// **'الخط'**
  String get settingsFont;

  /// No description provided for @settingsThemeColor.
  ///
  /// In ar, this message translates to:
  /// **'لون القالب'**
  String get settingsThemeColor;

  /// No description provided for @settingsLayoutDesign.
  ///
  /// In ar, this message translates to:
  /// **'تصميم الواجهة'**
  String get settingsLayoutDesign;

  /// No description provided for @settingsClockType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الساعة'**
  String get settingsClockType;

  /// No description provided for @layoutModern.
  ///
  /// In ar, this message translates to:
  /// **'حديث'**
  String get layoutModern;

  /// No description provided for @layoutClassic.
  ///
  /// In ar, this message translates to:
  /// **'كلاسيكي'**
  String get layoutClassic;

  /// No description provided for @clockDigital.
  ///
  /// In ar, this message translates to:
  /// **'رقمي'**
  String get clockDigital;

  /// No description provided for @clockAnalog.
  ///
  /// In ar, this message translates to:
  /// **'تناظري'**
  String get clockAnalog;

  /// No description provided for @fontCairo.
  ///
  /// In ar, this message translates to:
  /// **'كايرو'**
  String get fontCairo;

  /// No description provided for @fontBeiruti.
  ///
  /// In ar, this message translates to:
  /// **'بيروتي'**
  String get fontBeiruti;

  /// No description provided for @fontKufi.
  ///
  /// In ar, this message translates to:
  /// **'كوفي'**
  String get fontKufi;

  /// No description provided for @fontRubik.
  ///
  /// In ar, this message translates to:
  /// **'روبيك'**
  String get fontRubik;

  /// No description provided for @fontInter.
  ///
  /// In ar, this message translates to:
  /// **'Inter'**
  String get fontInter;

  /// No description provided for @themeGreen.
  ///
  /// In ar, this message translates to:
  /// **'زمردي'**
  String get themeGreen;

  /// No description provided for @themeTeal.
  ///
  /// In ar, this message translates to:
  /// **'فيروزي'**
  String get themeTeal;

  /// No description provided for @themeGold.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get themeGold;

  /// No description provided for @themeBlue.
  ///
  /// In ar, this message translates to:
  /// **'ياقوتي'**
  String get themeBlue;

  /// No description provided for @themePurple.
  ///
  /// In ar, this message translates to:
  /// **'بنفسجي'**
  String get themePurple;

  /// No description provided for @settingsAutoPlayAdhan.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الأذان تلقائياً:'**
  String get settingsAutoPlayAdhan;

  /// No description provided for @settingsChangeAdhan.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الأذان'**
  String get settingsChangeAdhan;

  /// No description provided for @settingsQuranInBackground.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل القرآن في الخلفية:'**
  String get settingsQuranInBackground;

  /// No description provided for @settingsNoReciterSelected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اختيار قارئ'**
  String get settingsNoReciterSelected;

  /// No description provided for @settingsChangeReciter.
  ///
  /// In ar, this message translates to:
  /// **'تغيير القارئ'**
  String get settingsChangeReciter;

  /// No description provided for @settingsInternetRequiredForQuran.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب اتصالاً بالإنترنت لتحميل قائمة القراء وتشغيل القرآن.'**
  String get settingsInternetRequiredForQuran;

  /// No description provided for @settingsMorningEveningAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح والمساء:'**
  String get settingsMorningEveningAdhkar;

  /// No description provided for @settingsAdhkarScheduleNote.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح: تظهر بعد الفجر حتى الساعة 10:00 صباحاً. أذكار المساء: تظهر بعد العصر وتنتهي قبل أذان المغرب بـ 5 دقائق. تظهر مرة واحدة في اليوم، وتُوقف مؤقتاً أثناء الأذان والإقامة.'**
  String get settingsAdhkarScheduleNote;

  /// No description provided for @settingsNoCitySelected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اختيار مدينة'**
  String get settingsNoCitySelected;

  /// No description provided for @settingsChangeCity.
  ///
  /// In ar, this message translates to:
  /// **'تغيير المدينة'**
  String get settingsChangeCity;

  /// No description provided for @settingsChangeCountry.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الدولة'**
  String get settingsChangeCountry;

  /// No description provided for @settingsCloseApp.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق التطبيق'**
  String get settingsCloseApp;

  /// No description provided for @settingsSelectReciter.
  ///
  /// In ar, this message translates to:
  /// **'اختر القارئ'**
  String get settingsSelectReciter;

  /// No description provided for @settingsFailedToLoadReciters.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل القائمة.\nتحقق من الاتصال بالإنترنت.'**
  String get settingsFailedToLoadReciters;

  /// No description provided for @settingsLoadingReciters.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل القراء...'**
  String get settingsLoadingReciters;

  /// No description provided for @adhanSound1.
  ///
  /// In ar, this message translates to:
  /// **'أذان 1'**
  String get adhanSound1;

  /// No description provided for @adhanSound2.
  ///
  /// In ar, this message translates to:
  /// **'أذان 2'**
  String get adhanSound2;

  /// No description provided for @adhanSoundAliMulla.
  ///
  /// In ar, this message translates to:
  /// **'الشيخ علي ملا'**
  String get adhanSoundAliMulla;

  /// No description provided for @adhanSoundAbdulbasit.
  ///
  /// In ar, this message translates to:
  /// **'الشيخ عبدالباسط عبدالصمد'**
  String get adhanSoundAbdulbasit;

  /// No description provided for @adhanSoundAqsa.
  ///
  /// In ar, this message translates to:
  /// **'أذان المسجد الأقصى'**
  String get adhanSoundAqsa;

  /// No description provided for @qiblaPermissionDeniedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الموقع مرفوض'**
  String get qiblaPermissionDeniedTitle;

  /// No description provided for @qiblaPermissionDeniedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يرجى السماح بالوصول إلى الموقع من الإعدادات'**
  String get qiblaPermissionDeniedSubtitle;

  /// No description provided for @qiblaGpsDisabledTitle.
  ///
  /// In ar, this message translates to:
  /// **'الـ GPS معطّل'**
  String get qiblaGpsDisabledTitle;

  /// No description provided for @qiblaGpsDisabledSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تفعيل خدمة الموقع'**
  String get qiblaGpsDisabledSubtitle;

  /// No description provided for @qiblaNotAvailableOnTv.
  ///
  /// In ar, this message translates to:
  /// **'القبلة غير متوفرة على أجهزة التلفاز'**
  String get qiblaNotAvailableOnTv;

  /// No description provided for @qiblaAlignedStatus.
  ///
  /// In ar, this message translates to:
  /// **'أنت تشير باتجاه القبلة'**
  String get qiblaAlignedStatus;

  /// No description provided for @qiblaFindStatus.
  ///
  /// In ar, this message translates to:
  /// **'اتجه نحو القبلة'**
  String get qiblaFindStatus;

  /// No description provided for @qiblaAlignedSub.
  ///
  /// In ar, this message translates to:
  /// **'ALIGNED WITH KAABA'**
  String get qiblaAlignedSub;

  /// No description provided for @qiblaFindSub.
  ///
  /// In ar, this message translates to:
  /// **'FIND THE KAABA'**
  String get qiblaFindSub;

  /// No description provided for @qiblaDistanceToKaaba.
  ///
  /// In ar, this message translates to:
  /// **'المسافة للكعبة'**
  String get qiblaDistanceToKaaba;

  /// No description provided for @qiblaDeviation.
  ///
  /// In ar, this message translates to:
  /// **'الانحراف'**
  String get qiblaDeviation;

  /// No description provided for @unitKm.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get unitKm;

  /// No description provided for @unitDegree.
  ///
  /// In ar, this message translates to:
  /// **'درجة'**
  String get unitDegree;

  /// No description provided for @weekdayMonday.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekdaySunday;

  /// No description provided for @gregorianMonthJanuary.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get gregorianMonthJanuary;

  /// No description provided for @gregorianMonthFebruary.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get gregorianMonthFebruary;

  /// No description provided for @gregorianMonthMarch.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get gregorianMonthMarch;

  /// No description provided for @gregorianMonthApril.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get gregorianMonthApril;

  /// No description provided for @gregorianMonthMay.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get gregorianMonthMay;

  /// No description provided for @gregorianMonthJune.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get gregorianMonthJune;

  /// No description provided for @gregorianMonthJuly.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get gregorianMonthJuly;

  /// No description provided for @gregorianMonthAugust.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get gregorianMonthAugust;

  /// No description provided for @gregorianMonthSeptember.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get gregorianMonthSeptember;

  /// No description provided for @gregorianMonthOctober.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get gregorianMonthOctober;

  /// No description provided for @gregorianMonthNovember.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get gregorianMonthNovember;

  /// No description provided for @gregorianMonthDecember.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get gregorianMonthDecember;

  /// No description provided for @hijriMonthMuharram.
  ///
  /// In ar, this message translates to:
  /// **'مُحَرَّم'**
  String get hijriMonthMuharram;

  /// No description provided for @hijriMonthSafar.
  ///
  /// In ar, this message translates to:
  /// **'صَفَر'**
  String get hijriMonthSafar;

  /// No description provided for @hijriMonthRabiAlAwwal.
  ///
  /// In ar, this message translates to:
  /// **'رَبِيع الأَوَّل'**
  String get hijriMonthRabiAlAwwal;

  /// No description provided for @hijriMonthRabiAlThani.
  ///
  /// In ar, this message translates to:
  /// **'رَبِيع الثَّانِي'**
  String get hijriMonthRabiAlThani;

  /// No description provided for @hijriMonthJumadaAlAwwal.
  ///
  /// In ar, this message translates to:
  /// **'جُمَادَى الأُولَى'**
  String get hijriMonthJumadaAlAwwal;

  /// No description provided for @hijriMonthJumadaAlAkhirah.
  ///
  /// In ar, this message translates to:
  /// **'جُمَادَى الآخِرَة'**
  String get hijriMonthJumadaAlAkhirah;

  /// No description provided for @hijriMonthRajab.
  ///
  /// In ar, this message translates to:
  /// **'رَجَب'**
  String get hijriMonthRajab;

  /// No description provided for @hijriMonthShaban.
  ///
  /// In ar, this message translates to:
  /// **'شَعْبَان'**
  String get hijriMonthShaban;

  /// No description provided for @hijriMonthRamadan.
  ///
  /// In ar, this message translates to:
  /// **'رَمَضَان'**
  String get hijriMonthRamadan;

  /// No description provided for @hijriMonthShawwal.
  ///
  /// In ar, this message translates to:
  /// **'شَوَّال'**
  String get hijriMonthShawwal;

  /// No description provided for @hijriMonthDhuAlQadah.
  ///
  /// In ar, this message translates to:
  /// **'ذُو القَعْدَة'**
  String get hijriMonthDhuAlQadah;

  /// No description provided for @hijriMonthDhuAlHijjah.
  ///
  /// In ar, this message translates to:
  /// **'ذُو الحِجَّة'**
  String get hijriMonthDhuAlHijjah;

  /// No description provided for @hijriYearSuffix.
  ///
  /// In ar, this message translates to:
  /// **'هـ'**
  String get hijriYearSuffix;

  /// No description provided for @gregorianYearSuffix.
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get gregorianYearSuffix;

  /// No description provided for @calcMethodMuslimWorldLeague.
  ///
  /// In ar, this message translates to:
  /// **'رابطة العالم الإسلامي'**
  String get calcMethodMuslimWorldLeague;

  /// No description provided for @calcMethodEgyptian.
  ///
  /// In ar, this message translates to:
  /// **'الهيئة المصرية العامة للمساحة'**
  String get calcMethodEgyptian;

  /// No description provided for @calcMethodKarachi.
  ///
  /// In ar, this message translates to:
  /// **'جامعة العلوم الإسلامية، كراتشي'**
  String get calcMethodKarachi;

  /// No description provided for @calcMethodUmmAlQura.
  ///
  /// In ar, this message translates to:
  /// **'أم القرى'**
  String get calcMethodUmmAlQura;

  /// No description provided for @calcMethodDubai.
  ///
  /// In ar, this message translates to:
  /// **'دبي'**
  String get calcMethodDubai;

  /// No description provided for @calcMethodQatar.
  ///
  /// In ar, this message translates to:
  /// **'قطر'**
  String get calcMethodQatar;

  /// No description provided for @calcMethodKuwait.
  ///
  /// In ar, this message translates to:
  /// **'الكويت'**
  String get calcMethodKuwait;

  /// No description provided for @calcMethodMorocco.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get calcMethodMorocco;

  /// No description provided for @calcMethodSingapore.
  ///
  /// In ar, this message translates to:
  /// **'سنغافورة'**
  String get calcMethodSingapore;

  /// No description provided for @calcMethodTehran.
  ///
  /// In ar, this message translates to:
  /// **'طهران'**
  String get calcMethodTehran;

  /// No description provided for @calcMethodTurkiye.
  ///
  /// In ar, this message translates to:
  /// **'تركيا (ديانت)'**
  String get calcMethodTurkiye;

  /// No description provided for @calcMethodNorthAmerica.
  ///
  /// In ar, this message translates to:
  /// **'أمريكا الشمالية (ISNA)'**
  String get calcMethodNorthAmerica;

  /// No description provided for @calcMethodMoonsightingCommittee.
  ///
  /// In ar, this message translates to:
  /// **'لجنة رؤية الهلال'**
  String get calcMethodMoonsightingCommittee;

  /// No description provided for @splashVerseStart.
  ///
  /// In ar, this message translates to:
  /// **'أَقِمِ ٱلصَّلَوٰةَ لِدُلُوكِ ٱلشَّمْسِ إِلَىٰ '**
  String get splashVerseStart;

  /// No description provided for @splashVerseHighlight.
  ///
  /// In ar, this message translates to:
  /// **'غَسَقِ'**
  String get splashVerseHighlight;

  /// No description provided for @splashVerseEnd.
  ///
  /// In ar, this message translates to:
  /// **' ٱلَّيْلِ'**
  String get splashVerseEnd;

  /// No description provided for @splashVerseReference.
  ///
  /// In ar, this message translates to:
  /// **'الإسراء: ٧٨'**
  String get splashVerseReference;

  /// No description provided for @fontPreviewSample.
  ///
  /// In ar, this message translates to:
  /// **'أبجد هوز'**
  String get fontPreviewSample;

  /// No description provided for @onboardingWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في غسق'**
  String get onboardingWelcome;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغتك المفضلة'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingSelectCountry.
  ///
  /// In ar, this message translates to:
  /// **'اختر بلدك'**
  String get onboardingSelectCountry;

  /// No description provided for @onboardingSelectCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر مدينتك'**
  String get onboardingSelectCity;

  /// No description provided for @onboardingStepLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get onboardingStepLanguage;

  /// No description provided for @onboardingStepLocation.
  ///
  /// In ar, this message translates to:
  /// **'البلد'**
  String get onboardingStepLocation;

  /// No description provided for @onboardingStepCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get onboardingStepCity;

  /// No description provided for @onboardingNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get onboardingFinish;

  /// No description provided for @todayPrayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة اليوم'**
  String get todayPrayerTimes;

  /// No description provided for @remainingHours.
  ///
  /// In ar, this message translates to:
  /// **'بعد {hours} س'**
  String remainingHours(int hours);

  /// No description provided for @remainingMinutes.
  ///
  /// In ar, this message translates to:
  /// **'بعد {minutes} د'**
  String remainingMinutes(int minutes);

  /// No description provided for @remainingHoursMinutes.
  ///
  /// In ar, this message translates to:
  /// **'بعد {hours} س {minutes} د'**
  String remainingHoursMinutes(int hours, int minutes);

  /// No description provided for @prayerPassed.
  ///
  /// In ar, this message translates to:
  /// **'أُديت'**
  String get prayerPassed;

  /// No description provided for @feedbackSection.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات وشكاوي'**
  String get feedbackSection;

  /// No description provided for @feedbackSettingsTile.
  ///
  /// In ar, this message translates to:
  /// **'أرسل ملاحظة'**
  String get feedbackSettingsTile;

  /// No description provided for @feedbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسل ملاحظة'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شاركنا آراءك واقتراحاتك'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackTypeOther.
  ///
  /// In ar, this message translates to:
  /// **'شكوى'**
  String get feedbackTypeOther;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'صف ملاحظتك...'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الملاحظة'**
  String get feedbackSend;

  /// No description provided for @feedbackSuccess.
  ///
  /// In ar, this message translates to:
  /// **'شكراً! تم إرسال ملاحظتك بنجاح.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ. حاول مرة أخرى.'**
  String get feedbackError;

  /// No description provided for @feedbackEmptyError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة ملاحظتك أولاً'**
  String get feedbackEmptyError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
