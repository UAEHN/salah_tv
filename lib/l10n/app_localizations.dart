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

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

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
  /// **'مواقيت الصلاة'**
  String get navPrayer;

  /// No description provided for @navTasbih.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get navTasbih;

  /// No description provided for @navToday.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الرئيسية'**
  String get navToday;

  /// No description provided for @navMushaf.
  ///
  /// In ar, this message translates to:
  /// **'القرآن'**
  String get navMushaf;

  /// No description provided for @todayTitle.
  ///
  /// In ar, this message translates to:
  /// **'يومك'**
  String get todayTitle;

  /// No description provided for @todayNextPrayerTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get todayNextPrayerTitle;

  /// No description provided for @todayHijriDateTitle.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ اليوم'**
  String get todayHijriDateTitle;

  /// No description provided for @todayDailyVerseTitle.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get todayDailyVerseTitle;

  /// No description provided for @todayUpcomingOccasionTitle.
  ///
  /// In ar, this message translates to:
  /// **'مناسبة قريبة'**
  String get todayUpcomingOccasionTitle;

  /// No description provided for @todayOccasionToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get todayOccasionToday;

  /// No description provided for @todayOccasionTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get todayOccasionTomorrow;

  /// No description provided for @todayDaysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقي {days} أيام'**
  String todayDaysRemaining(int days);

  /// No description provided for @todayDayRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقي يوم واحد'**
  String get todayDayRemaining;

  /// No description provided for @todayPrayerStartsIn.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ بعد'**
  String get todayPrayerStartsIn;

  /// No description provided for @todayMetaDot.
  ///
  /// In ar, this message translates to:
  /// **' · '**
  String get todayMetaDot;

  /// No description provided for @todayVerseSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get todayVerseSectionLabel;

  /// No description provided for @todayDaysUnit.
  ///
  /// In ar, this message translates to:
  /// **'أيام'**
  String get todayDaysUnit;

  /// No description provided for @todayLiveBadge.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get todayLiveBadge;

  /// No description provided for @todayPrayersStripTitle.
  ///
  /// In ar, this message translates to:
  /// **'صلوات اليوم'**
  String get todayPrayersStripTitle;

  /// No description provided for @todayQiblaTileLabel.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get todayQiblaTileLabel;

  /// No description provided for @todayQiblaKmUnit.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get todayQiblaKmUnit;

  /// No description provided for @todayQuickActionTasbih.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get todayQuickActionTasbih;

  /// No description provided for @todayQuickActionAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get todayQuickActionAdhkar;

  /// No description provided for @todayQuickActionQibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get todayQuickActionQibla;

  /// No description provided for @todayQuickAccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع'**
  String get todayQuickAccessTitle;

  /// No description provided for @todayDhikrEyebrow.
  ///
  /// In ar, this message translates to:
  /// **'ذكر هذا الوقت'**
  String get todayDhikrEyebrow;

  /// No description provided for @todayDhikrTitleMorning.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get todayDhikrTitleMorning;

  /// No description provided for @todayDhikrTitleEvening.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get todayDhikrTitleEvening;

  /// No description provided for @todayDhikrTitleSleep.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get todayDhikrTitleSleep;

  /// No description provided for @todayDhikrStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get todayDhikrStart;

  /// No description provided for @greetingMorningTitle.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get greetingMorningTitle;

  /// No description provided for @greetingMorningSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بدايةً مباركة بإذن الله'**
  String get greetingMorningSubtitle;

  /// No description provided for @greetingNoonTitle.
  ///
  /// In ar, this message translates to:
  /// **'نهارك مبارك'**
  String get greetingNoonTitle;

  /// No description provided for @greetingNoonSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أحسن الله إليك في عملك'**
  String get greetingNoonSubtitle;

  /// No description provided for @greetingEveningTitle.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get greetingEveningTitle;

  /// No description provided for @greetingEveningSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختم يومك بالطاعة'**
  String get greetingEveningSubtitle;

  /// No description provided for @greetingNightTitle.
  ///
  /// In ar, this message translates to:
  /// **'ليلة طيبة'**
  String get greetingNightTitle;

  /// No description provided for @greetingNightSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أكثر من الذكر قبل النوم'**
  String get greetingNightSubtitle;

  /// No description provided for @occasionHijriNewYear.
  ///
  /// In ar, this message translates to:
  /// **'رأس السنة الهجرية'**
  String get occasionHijriNewYear;

  /// No description provided for @occasionAshura.
  ///
  /// In ar, this message translates to:
  /// **'عاشوراء'**
  String get occasionAshura;

  /// No description provided for @occasionMawlid.
  ///
  /// In ar, this message translates to:
  /// **'المولد النبوي'**
  String get occasionMawlid;

  /// No description provided for @occasionIsraMiraj.
  ///
  /// In ar, this message translates to:
  /// **'الإسراء والمعراج'**
  String get occasionIsraMiraj;

  /// No description provided for @occasionMidShaban.
  ///
  /// In ar, this message translates to:
  /// **'ليلة النصف من شعبان'**
  String get occasionMidShaban;

  /// No description provided for @occasionRamadanStart.
  ///
  /// In ar, this message translates to:
  /// **'بداية شهر رمضان'**
  String get occasionRamadanStart;

  /// No description provided for @occasionLaylatQadr.
  ///
  /// In ar, this message translates to:
  /// **'ليلة القدر'**
  String get occasionLaylatQadr;

  /// No description provided for @occasionEidFitr.
  ///
  /// In ar, this message translates to:
  /// **'عيد الفطر'**
  String get occasionEidFitr;

  /// No description provided for @occasionArafah.
  ///
  /// In ar, this message translates to:
  /// **'يوم عرفة'**
  String get occasionArafah;

  /// No description provided for @occasionEidAdha.
  ///
  /// In ar, this message translates to:
  /// **'عيد الأضحى'**
  String get occasionEidAdha;

  /// No description provided for @surahBaqarah.
  ///
  /// In ar, this message translates to:
  /// **'البقرة'**
  String get surahBaqarah;

  /// No description provided for @surahAlImran.
  ///
  /// In ar, this message translates to:
  /// **'آل عمران'**
  String get surahAlImran;

  /// No description provided for @surahAnam.
  ///
  /// In ar, this message translates to:
  /// **'الأنعام'**
  String get surahAnam;

  /// No description provided for @surahAraf.
  ///
  /// In ar, this message translates to:
  /// **'الأعراف'**
  String get surahAraf;

  /// No description provided for @surahTawbah.
  ///
  /// In ar, this message translates to:
  /// **'التوبة'**
  String get surahTawbah;

  /// No description provided for @surahHud.
  ///
  /// In ar, this message translates to:
  /// **'هود'**
  String get surahHud;

  /// No description provided for @surahRad.
  ///
  /// In ar, this message translates to:
  /// **'الرعد'**
  String get surahRad;

  /// No description provided for @surahIbrahim.
  ///
  /// In ar, this message translates to:
  /// **'إبراهيم'**
  String get surahIbrahim;

  /// No description provided for @surahNahl.
  ///
  /// In ar, this message translates to:
  /// **'النحل'**
  String get surahNahl;

  /// No description provided for @surahIsra.
  ///
  /// In ar, this message translates to:
  /// **'الإسراء'**
  String get surahIsra;

  /// No description provided for @surahTaha.
  ///
  /// In ar, this message translates to:
  /// **'طه'**
  String get surahTaha;

  /// No description provided for @surahAnbiya.
  ///
  /// In ar, this message translates to:
  /// **'الأنبياء'**
  String get surahAnbiya;

  /// No description provided for @surahFurqan.
  ///
  /// In ar, this message translates to:
  /// **'الفرقان'**
  String get surahFurqan;

  /// No description provided for @surahQasas.
  ///
  /// In ar, this message translates to:
  /// **'القصص'**
  String get surahQasas;

  /// No description provided for @surahAnkabut.
  ///
  /// In ar, this message translates to:
  /// **'العنكبوت'**
  String get surahAnkabut;

  /// No description provided for @surahAhzab.
  ///
  /// In ar, this message translates to:
  /// **'الأحزاب'**
  String get surahAhzab;

  /// No description provided for @surahZumar.
  ///
  /// In ar, this message translates to:
  /// **'الزمر'**
  String get surahZumar;

  /// No description provided for @surahGhafir.
  ///
  /// In ar, this message translates to:
  /// **'غافر'**
  String get surahGhafir;

  /// No description provided for @surahShura.
  ///
  /// In ar, this message translates to:
  /// **'الشورى'**
  String get surahShura;

  /// No description provided for @surahHujurat.
  ///
  /// In ar, this message translates to:
  /// **'الحجرات'**
  String get surahHujurat;

  /// No description provided for @surahDhariyat.
  ///
  /// In ar, this message translates to:
  /// **'الذاريات'**
  String get surahDhariyat;

  /// No description provided for @surahRahman.
  ///
  /// In ar, this message translates to:
  /// **'الرحمن'**
  String get surahRahman;

  /// No description provided for @surahTalaq.
  ///
  /// In ar, this message translates to:
  /// **'الطلاق'**
  String get surahTalaq;

  /// No description provided for @surahInsan.
  ///
  /// In ar, this message translates to:
  /// **'الإنسان'**
  String get surahInsan;

  /// No description provided for @surahDuha.
  ///
  /// In ar, this message translates to:
  /// **'الضحى'**
  String get surahDuha;

  /// No description provided for @surahSharh.
  ///
  /// In ar, this message translates to:
  /// **'الشرح'**
  String get surahSharh;

  /// No description provided for @surahAsr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get surahAsr;

  /// No description provided for @surahIkhlas.
  ///
  /// In ar, this message translates to:
  /// **'الإخلاص'**
  String get surahIkhlas;

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

  /// No description provided for @adhkarAfterPrayerTitle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار بعد الصلاة'**
  String get adhkarAfterPrayerTitle;

  /// No description provided for @settingsAfterPrayerAdhkarNote.
  ///
  /// In ar, this message translates to:
  /// **'تُعرض أذكار ودعاء قصير على الشاشة بعد كل صلاة بدقائق، ثم يعود تشغيل القرآن. أوقفه إذا أردت ألّا تظهر بعد الصلاة.'**
  String get settingsAfterPrayerAdhkarNote;

  /// No description provided for @settingsScreensaverPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة شاشة التوقّف'**
  String get settingsScreensaverPreview;

  /// No description provided for @settingsScreensaver.
  ///
  /// In ar, this message translates to:
  /// **'شاشة التوقّف'**
  String get settingsScreensaver;

  /// No description provided for @settingsScreensaverNote.
  ///
  /// In ar, this message translates to:
  /// **'تعرض آيات وأذكار وأسماء الله الحسنى عند عدم استخدام الريموت، وتختفي فوراً عند أي ضغطة أو قرب الصلاة.'**
  String get settingsScreensaverNote;

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

  /// No description provided for @tasbihAllCompletedTitle.
  ///
  /// In ar, this message translates to:
  /// **'بارك الله فيك'**
  String get tasbihAllCompletedTitle;

  /// No description provided for @tasbihAllCompletedBody.
  ///
  /// In ar, this message translates to:
  /// **'أتممت التسبيح، تقبّل الله منك'**
  String get tasbihAllCompletedBody;

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

  /// No description provided for @prayerJumua.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get prayerJumua;

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

  /// No description provided for @nextPrayerShortLabel.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get nextPrayerShortLabel;

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

  /// No description provided for @notificationMorningAdhkarTitle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get notificationMorningAdhkarTitle;

  /// No description provided for @notificationMorningAdhkarBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسى أذكار الصباح'**
  String get notificationMorningAdhkarBody;

  /// No description provided for @notificationEveningAdhkarTitle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get notificationEveningAdhkarTitle;

  /// No description provided for @notificationEveningAdhkarBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسى أذكار المساء'**
  String get notificationEveningAdhkarBody;

  /// No description provided for @notificationAlKahfTitle.
  ///
  /// In ar, this message translates to:
  /// **'جمعة مباركة 🌸'**
  String get notificationAlKahfTitle;

  /// No description provided for @notificationAlKahfBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسَ سورة الكهف — نور لك بين الجمعتين'**
  String get notificationAlKahfBody;

  /// No description provided for @settingsAlKahfReminderTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير سورة الكهف'**
  String get settingsAlKahfReminderTitle;

  /// No description provided for @settingsAlKahfReminderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار أسبوعي يوم الجمعة بقراءة سورة الكهف'**
  String get settingsAlKahfReminderSubtitle;

  /// No description provided for @settingsAlKahfReminderOffsetTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير'**
  String get settingsAlKahfReminderOffsetTitle;

  /// No description provided for @settingsAdhkarNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الأذكار'**
  String get settingsAdhkarNotificationsTitle;

  /// No description provided for @settingsMorningAdhkarToggle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get settingsMorningAdhkarToggle;

  /// No description provided for @settingsEveningAdhkarToggle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get settingsEveningAdhkarToggle;

  /// No description provided for @settingsAdhkarOffsetTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت تنبيه الأذكار'**
  String get settingsAdhkarOffsetTitle;

  /// No description provided for @notificationAdhanBody.
  ///
  /// In ar, this message translates to:
  /// **'حان الآن موعد أذان {prayerName}'**
  String notificationAdhanBody(Object prayerName);

  /// No description provided for @notificationPreAdhanBody.
  ///
  /// In ar, this message translates to:
  /// **'باقي {minutes} دقيقة على أذان {prayerName}'**
  String notificationPreAdhanBody(Object prayerName, Object minutes);

  /// No description provided for @notificationPreIqamaBody.
  ///
  /// In ar, this message translates to:
  /// **'باقي {minutes} دقيقة على إقامة {prayerName}'**
  String notificationPreIqamaBody(Object prayerName, Object minutes);

  /// No description provided for @notificationIqamaBody.
  ///
  /// In ar, this message translates to:
  /// **'إقامة صلاة {prayerName}'**
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

  /// No description provided for @settingsSystemMode.
  ///
  /// In ar, this message translates to:
  /// **'تبعاً للنظام'**
  String get settingsSystemMode;

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

  /// No description provided for @settingsCustomAdhansTitle.
  ///
  /// In ar, this message translates to:
  /// **'أصوات أذان مخصّصة'**
  String get settingsCustomAdhansTitle;

  /// No description provided for @settingsAddCustomAdhan.
  ///
  /// In ar, this message translates to:
  /// **'إضافة من الجهاز'**
  String get settingsAddCustomAdhan;

  /// No description provided for @settingsRenameAdhan.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسمية الأذان'**
  String get settingsRenameAdhan;

  /// No description provided for @settingsDeleteAdhan.
  ///
  /// In ar, this message translates to:
  /// **'حذف الأذان؟'**
  String get settingsDeleteAdhan;

  /// No description provided for @settingsAdhanNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الأذان'**
  String get settingsAdhanNameHint;

  /// No description provided for @settingsPickFromDevice.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملفاً صوتياً'**
  String get settingsPickFromDevice;

  /// No description provided for @settingsAdhanImportFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر استيراد الملف'**
  String get settingsAdhanImportFailed;

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

  /// No description provided for @settingsDetectLocationHint.
  ///
  /// In ar, this message translates to:
  /// **'إذا لم تجد دولتك في القائمة، أو أردت الوصول إليها بسرعة، استخدم هذا الزر لتحديد موقعك تلقائياً.'**
  String get settingsDetectLocationHint;

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

  /// No description provided for @settingsSearchOnline.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الإنترنت'**
  String get settingsSearchOnline;

  /// No description provided for @settingsSearchOnlineHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم أي مدينة في العالم'**
  String get settingsSearchOnlineHint;

  /// No description provided for @settingsSearchOnlinePrompt.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم مدينتك لبدء البحث'**
  String get settingsSearchOnlinePrompt;

  /// No description provided for @settingsSearchOnlineEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد نتائج. جرّب اسماً آخر أو الإنجليزية.'**
  String get settingsSearchOnlineEmpty;

  /// No description provided for @settingsSearchOnlineError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالإنترنت. حاول لاحقاً.'**
  String get settingsSearchOnlineError;

  /// No description provided for @settingsSearchOnlineCta.
  ///
  /// In ar, this message translates to:
  /// **'لم تجد مدينتك؟ ابحث في الإنترنت'**
  String get settingsSearchOnlineCta;

  /// No description provided for @settingsPickCalculationMethod.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة الحساب'**
  String get settingsPickCalculationMethod;

  /// No description provided for @settingsSuggestedForLocation.
  ///
  /// In ar, this message translates to:
  /// **'موصى بها لموقعك'**
  String get settingsSuggestedForLocation;

  /// No description provided for @settingsOtherMethods.
  ///
  /// In ar, this message translates to:
  /// **'طرق أخرى'**
  String get settingsOtherMethods;

  /// No description provided for @settingsHighLatitudeMessage.
  ///
  /// In ar, this message translates to:
  /// **'أنت في منطقة عالية خط العرض. اخترنا قاعدة (زاوية الشفق) للفجر والعشاء — هذه الطريقة الأنسب لمعظم المساجد الأوروبية.'**
  String get settingsHighLatitudeMessage;

  /// No description provided for @settingsExtremeLatitudeMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذه منطقة قريبة من القطب. أوقات الفجر والعشاء في أيام الصيف ستكون تقديرية — تابع جدول مسجدك المحلي للأدق.'**
  String get settingsExtremeLatitudeMessage;

  /// No description provided for @settingsCalibrationPromptTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مطابقة مسجد محلي؟'**
  String get settingsCalibrationPromptTitle;

  /// No description provided for @settingsCalibrationPromptBody.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ موقعك بنجاح. إن كانت أوقات مسجدك تختلف بدقائق قليلة، يمكنك ضبط ±دقائق لكل صلاة لمطابقته تماماً.'**
  String get settingsCalibrationPromptBody;

  /// No description provided for @settingsCalibrationPromptYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم، اضبط الآن'**
  String get settingsCalibrationPromptYes;

  /// No description provided for @settingsCalibrationPromptSkip.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get settingsCalibrationPromptSkip;

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
  /// **'الأذان والإقامة'**
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

  /// No description provided for @settingsCategoryFeatures.
  ///
  /// In ar, this message translates to:
  /// **'المميزات'**
  String get settingsCategoryFeatures;

  /// No description provided for @settingsCategoryFeaturesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شريط الآيات وشاشة التوقّف'**
  String get settingsCategoryFeaturesSubtitle;

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

  /// No description provided for @settingsTicker.
  ///
  /// In ar, this message translates to:
  /// **'الشريط المتحرّك'**
  String get settingsTicker;

  /// No description provided for @settingsTickerLabel.
  ///
  /// In ar, this message translates to:
  /// **'شريط متحرّك أسفل الشاشة يعرض آيات وأذكار'**
  String get settingsTickerLabel;

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

  /// No description provided for @themeCoral.
  ///
  /// In ar, this message translates to:
  /// **'مرجاني'**
  String get themeCoral;

  /// No description provided for @themeAzure.
  ///
  /// In ar, this message translates to:
  /// **'سماوي'**
  String get themeAzure;

  /// No description provided for @themePickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'ألوان التطبيق'**
  String get themePickerTitle;

  /// No description provided for @themePickerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللون الذي يلامس روحك'**
  String get themePickerSubtitle;

  /// No description provided for @themePickerLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الألوان'**
  String get themePickerLoadError;

  /// No description provided for @fontHintKufi.
  ///
  /// In ar, this message translates to:
  /// **'خط كوفي معاصر'**
  String get fontHintKufi;

  /// No description provided for @fontHintCairo.
  ///
  /// In ar, this message translates to:
  /// **'خط حديث متعدد الأوزان'**
  String get fontHintCairo;

  /// No description provided for @fontHintBeiruti.
  ///
  /// In ar, this message translates to:
  /// **'خط أنيق للعناوين'**
  String get fontHintBeiruti;

  /// No description provided for @fontHintRubik.
  ///
  /// In ar, this message translates to:
  /// **'خط لاتيني عصري'**
  String get fontHintRubik;

  /// No description provided for @fontHintInter.
  ///
  /// In ar, this message translates to:
  /// **'خط لاتيني واضح للقراءة'**
  String get fontHintInter;

  /// No description provided for @fontPickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الخط'**
  String get fontPickerTitle;

  /// No description provided for @fontPickerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خط يناسب قراءتك للقرآن والأذكار'**
  String get fontPickerSubtitle;

  /// No description provided for @fontPickerLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الخطوط'**
  String get fontPickerLoadError;

  /// No description provided for @settingsThemePicker.
  ///
  /// In ar, this message translates to:
  /// **'ألوان التطبيق'**
  String get settingsThemePicker;

  /// No description provided for @settingsFontPicker.
  ///
  /// In ar, this message translates to:
  /// **'خط النصوص'**
  String get settingsFontPicker;

  /// No description provided for @settingsAutoPlayAdhan.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الأذان تلقائياً:'**
  String get settingsAutoPlayAdhan;

  /// No description provided for @settingsAutoPlayIqama.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الإقامة تلقائياً:'**
  String get settingsAutoPlayIqama;

  /// No description provided for @settingsSoundModeSound.
  ///
  /// In ar, this message translates to:
  /// **'بصوت'**
  String get settingsSoundModeSound;

  /// No description provided for @settingsSoundModeSilent.
  ///
  /// In ar, this message translates to:
  /// **'بدون صوت'**
  String get settingsSoundModeSilent;

  /// No description provided for @settingsSoundModeOff.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get settingsSoundModeOff;

  /// No description provided for @settingsSoundModeSoundDesc.
  ///
  /// In ar, this message translates to:
  /// **'يعرض الشاشة ويشغّل الصوت'**
  String get settingsSoundModeSoundDesc;

  /// No description provided for @settingsSoundModeSilentDesc.
  ///
  /// In ar, this message translates to:
  /// **'يعرض الشاشة فقط بدون صوت'**
  String get settingsSoundModeSilentDesc;

  /// No description provided for @settingsSoundModeOffDesc.
  ///
  /// In ar, this message translates to:
  /// **'لا شاشة ولا صوت — يستمر العدّاد للصلاة التالية'**
  String get settingsSoundModeOffDesc;

  /// No description provided for @adhanLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأذان'**
  String get adhanLabel;

  /// No description provided for @settingsCategoryMosque.
  ///
  /// In ar, this message translates to:
  /// **'وضع المسجد'**
  String get settingsCategoryMosque;

  /// No description provided for @settingsCategoryMosqueSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات خاصة لشاشات المساجد'**
  String get settingsCategoryMosqueSubtitle;

  /// No description provided for @settingsMosqueMode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل وضع المسجد:'**
  String get settingsMosqueMode;

  /// No description provided for @settingsMosqueModeDesc.
  ///
  /// In ar, this message translates to:
  /// **'شاشة كبيرة بدون صوت، مخصصة للعرض في المساجد.'**
  String get settingsMosqueModeDesc;

  /// No description provided for @mosqueAdhanNowTitle.
  ///
  /// In ar, this message translates to:
  /// **'حان الآن موعد أذان {prayerName}'**
  String mosqueAdhanNowTitle(String prayerName);

  /// No description provided for @mosqueIqamaLabel.
  ///
  /// In ar, this message translates to:
  /// **'إقامة صلاة'**
  String get mosqueIqamaLabel;

  /// No description provided for @mosqueSilencePhoneText.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إغلاق الهاتف'**
  String get mosqueSilencePhoneText;

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

  /// No description provided for @reciterFavoritesSection.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get reciterFavoritesSection;

  /// No description provided for @reciterAllSection.
  ///
  /// In ar, this message translates to:
  /// **'كل القراء'**
  String get reciterAllSection;

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

  /// No description provided for @qiblaAccuracyHigh.
  ///
  /// In ar, this message translates to:
  /// **'دقة عالية'**
  String get qiblaAccuracyHigh;

  /// No description provided for @qiblaAccuracyMedium.
  ///
  /// In ar, this message translates to:
  /// **'دقة متوسطة'**
  String get qiblaAccuracyMedium;

  /// No description provided for @qiblaAccuracyLow.
  ///
  /// In ar, this message translates to:
  /// **'دقة منخفضة'**
  String get qiblaAccuracyLow;

  /// No description provided for @qiblaCalibrationTitle.
  ///
  /// In ar, this message translates to:
  /// **'يوجد تداخل مغناطيسي'**
  String get qiblaCalibrationTitle;

  /// No description provided for @qiblaCalibrationBody.
  ///
  /// In ar, this message translates to:
  /// **'حرّك الهاتف على شكل رقم 8 لمعايرة البوصلة'**
  String get qiblaCalibrationBody;

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

  /// No description provided for @calcMethodFrance.
  ///
  /// In ar, this message translates to:
  /// **'فرنسا (مسجد باريس الكبير)'**
  String get calcMethodFrance;

  /// No description provided for @calcMethodUoif.
  ///
  /// In ar, this message translates to:
  /// **'فرنسا (UOIF 15°)'**
  String get calcMethodUoif;

  /// No description provided for @calcMethodUk.
  ///
  /// In ar, this message translates to:
  /// **'المملكة المتحدة (لندن سنترال موسك)'**
  String get calcMethodUk;

  /// No description provided for @calcMethodGermany.
  ///
  /// In ar, this message translates to:
  /// **'ألمانيا / شمال أوروبا (18°/17°)'**
  String get calcMethodGermany;

  /// No description provided for @calcMethodRussia.
  ///
  /// In ar, this message translates to:
  /// **'روسيا / شرق أوروبا (16°/15°)'**
  String get calcMethodRussia;

  /// No description provided for @calcMethodJafari.
  ///
  /// In ar, this message translates to:
  /// **'الجعفري (16°/14°)'**
  String get calcMethodJafari;

  /// No description provided for @settingsHighLatitudeLabel.
  ///
  /// In ar, this message translates to:
  /// **'ضبط خطوط العرض العالية'**
  String get settingsHighLatitudeLabel;

  /// No description provided for @settingsHighLatitudeNote.
  ///
  /// In ar, this message translates to:
  /// **'في الدول الأوروبية تختلف طرق حساب الفجر والعشاء عند المدن الشمالية. اختر الطريقة التي يعتمدها مسجدك المحلي.'**
  String get settingsHighLatitudeNote;

  /// No description provided for @settingsHighLatitudeAffectsNote.
  ///
  /// In ar, this message translates to:
  /// **'تؤثر فقط على الفجر والعشاء في المدن فوق ~48° شمالاً'**
  String get settingsHighLatitudeAffectsNote;

  /// No description provided for @highLatRuleAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (مُوصى به)'**
  String get highLatRuleAuto;

  /// No description provided for @highLatRuleAutoSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق منتصف الليل تلقائياً عند خطوط العرض العالية'**
  String get highLatRuleAutoSubtitle;

  /// No description provided for @highLatRuleMiddleOfNight.
  ///
  /// In ar, this message translates to:
  /// **'منتصف الليل'**
  String get highLatRuleMiddleOfNight;

  /// No description provided for @highLatRuleMiddleOfNightSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الفجر والعشاء في منتصف الليل بين المغرب والشروق'**
  String get highLatRuleMiddleOfNightSubtitle;

  /// No description provided for @highLatRuleSeventhOfNight.
  ///
  /// In ar, this message translates to:
  /// **'سُبع الليل'**
  String get highLatRuleSeventhOfNight;

  /// No description provided for @highLatRuleSeventhOfNightSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الفجر بعد سُبع الليل من المغرب، والعشاء قبله بسُبع'**
  String get highLatRuleSeventhOfNightSubtitle;

  /// No description provided for @highLatRuleTwilightAngle.
  ///
  /// In ar, this message translates to:
  /// **'زاوية الشفق'**
  String get highLatRuleTwilightAngle;

  /// No description provided for @highLatRuleTwilightAngleSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تخفيف زاوية الشفق تدريجياً مع طول النهار'**
  String get highLatRuleTwilightAngleSubtitle;

  /// No description provided for @calculationMethodOfficialScheduleNote.
  ///
  /// In ar, this message translates to:
  /// **'هذا البلد يستخدم الجدول الرسمي — هذا الخيار للعرض فقط ولا يؤثر على المواقيت'**
  String get calculationMethodOfficialScheduleNote;

  /// No description provided for @surahRevelationMakki.
  ///
  /// In ar, this message translates to:
  /// **'مكية'**
  String get surahRevelationMakki;

  /// No description provided for @surahRevelationMadani.
  ///
  /// In ar, this message translates to:
  /// **'مدنية'**
  String get surahRevelationMadani;

  /// No description provided for @surahAyahCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'آياتها'**
  String get surahAyahCountLabel;

  /// No description provided for @surahOrderLabel.
  ///
  /// In ar, this message translates to:
  /// **'ترتيبها'**
  String get surahOrderLabel;

  /// No description provided for @quranAssetsDownloadTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل المصحف'**
  String get quranAssetsDownloadTitle;

  /// No description provided for @quranAssetsDownloadSize.
  ///
  /// In ar, this message translates to:
  /// **'الحجم: ~105 ميجابايت'**
  String get quranAssetsDownloadSize;

  /// No description provided for @quranAssetsBackgroundHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إغلاق هذه الصفحة — التنزيل يكمل في الخلفية'**
  String get quranAssetsBackgroundHint;

  /// No description provided for @quranAssetsDownloadButton.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل'**
  String get quranAssetsDownloadButton;

  /// No description provided for @quranAssetsDownloadingTitle.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنزيل…'**
  String get quranAssetsDownloadingTitle;

  /// No description provided for @quranAssetsDownloadProgress.
  ///
  /// In ar, this message translates to:
  /// **'{done} / {total}'**
  String quranAssetsDownloadProgress(Object done, Object total);

  /// No description provided for @quranAssetsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get quranAssetsCancel;

  /// No description provided for @quranAssetsDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المصحف'**
  String get quranAssetsDeleteTitle;

  /// No description provided for @quranAssetsDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف خطوط المصحف من جهازك؟ يمكنك تنزيلها مرة أخرى لاحقاً.'**
  String get quranAssetsDeleteConfirm;

  /// No description provided for @quranAssetsDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get quranAssetsDelete;

  /// No description provided for @quranAssetsDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المصحف'**
  String get quranAssetsDeleted;

  /// No description provided for @quranAssetsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get quranAssetsRetry;

  /// No description provided for @quranAssetsReady.
  ///
  /// In ar, this message translates to:
  /// **'المصحف جاهز'**
  String get quranAssetsReady;

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

  /// No description provided for @onboardingHeroTagline.
  ///
  /// In ar, this message translates to:
  /// **'رفيقك اليومي للصلاة والذِّكر'**
  String get onboardingHeroTagline;

  /// No description provided for @onboardingBegin.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get onboardingBegin;

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

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد موقعك'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم GPS أو ابحث عن مدينتك'**
  String get onboardingLocationSubtitle;

  /// No description provided for @onboardingConfirmLocationTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت في:'**
  String get onboardingConfirmLocationTitle;

  /// No description provided for @onboardingConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get onboardingConfirmAction;

  /// No description provided for @onboardingChangeAction.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get onboardingChangeAction;

  /// No description provided for @onboardingOrSearchManually.
  ///
  /// In ar, this message translates to:
  /// **'أو ابحث يدوياً'**
  String get onboardingOrSearchManually;

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

  /// No description provided for @feedbackContactLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد أو معرّف تيليجرام'**
  String get feedbackContactLabel;

  /// No description provided for @feedbackContactHint.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب للرد عليك ومتابعة المشكلة'**
  String get feedbackContactHint;

  /// No description provided for @feedbackContactRequiredError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال البريد أو معرّف تيليجرام للتواصل معك'**
  String get feedbackContactRequiredError;

  /// No description provided for @feedbackDirectContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'أو تواصل معنا مباشرة'**
  String get feedbackDirectContactTitle;

  /// No description provided for @feedbackContactEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get feedbackContactEmail;

  /// No description provided for @feedbackContactTelegram.
  ///
  /// In ar, this message translates to:
  /// **'تيليجرام'**
  String get feedbackContactTelegram;

  /// No description provided for @feedbackEmailSubject.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة على تطبيق غسق'**
  String get feedbackEmailSubject;

  /// No description provided for @feedbackEmailBodyPrompt.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك هنا...'**
  String get feedbackEmailBodyPrompt;

  /// No description provided for @feedbackTelegramCopiedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ معلومات التشخيص — الصقها في رسالتك على تيليجرام'**
  String get feedbackTelegramCopiedToast;

  /// No description provided for @feedbackTvQrTelegram.
  ///
  /// In ar, this message translates to:
  /// **'امسح للتواصل عبر تيليجرام'**
  String get feedbackTvQrTelegram;

  /// No description provided for @feedbackTvOrEmail.
  ///
  /// In ar, this message translates to:
  /// **'أو عبر البريد:'**
  String get feedbackTvOrEmail;

  /// No description provided for @feedbackTvDirectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا مباشرة من الهاتف'**
  String get feedbackTvDirectTitle;

  /// No description provided for @feedbackTvQrEmail.
  ///
  /// In ar, this message translates to:
  /// **'امسح للمراسلة عبر البريد'**
  String get feedbackTvQrEmail;

  /// No description provided for @feedbackTvOrFromPhone.
  ///
  /// In ar, this message translates to:
  /// **'أو من الهاتف مباشرة:'**
  String get feedbackTvOrFromPhone;

  /// No description provided for @ratingDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك معنا؟'**
  String get ratingDialogTitle;

  /// No description provided for @ratingDialogSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'دعمك لنا بالتقييم 5 نجوم يساعدنا في الاستمرار وتطوير التطبيق للأفضل 💖'**
  String get ratingDialogSubtitle;

  /// No description provided for @ratingDialogYes.
  ///
  /// In ar, this message translates to:
  /// **'التقييم الآن ⭐'**
  String get ratingDialogYes;

  /// No description provided for @ratingDialogQrRate.
  ///
  /// In ar, this message translates to:
  /// **'أو امسح الرمز للتقييم بهاتفك'**
  String get ratingDialogQrRate;

  /// No description provided for @ratingDialogSuggest.
  ///
  /// In ar, this message translates to:
  /// **'لدي اقتراح / مشكلة 💡'**
  String get ratingDialogSuggest;

  /// No description provided for @ratingDialogLater.
  ///
  /// In ar, this message translates to:
  /// **'ذكرني لاحقاً'**
  String get ratingDialogLater;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث متاح'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version} متاح الآن في المتجر.'**
  String updateAvailableBody(Object version);

  /// No description provided for @updateNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get updateLater;

  /// No description provided for @whatsNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما الجديد'**
  String get whatsNewTitle;

  /// No description provided for @whatsNewDismiss.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get whatsNewDismiss;

  /// No description provided for @settingsCheckUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من وجود تحديث'**
  String get settingsCheckUpdate;

  /// No description provided for @settingsQuranPlaybackMode.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد أن تسمع؟'**
  String get settingsQuranPlaybackMode;

  /// No description provided for @settingsQuranModeContinuous.
  ///
  /// In ar, this message translates to:
  /// **'المصحف كاملاً'**
  String get settingsQuranModeContinuous;

  /// No description provided for @settingsQuranModeContinuousDesc.
  ///
  /// In ar, this message translates to:
  /// **'من الفاتحة إلى الناس بالترتيب'**
  String get settingsQuranModeContinuousDesc;

  /// No description provided for @settingsQuranContinuousStart.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البداية'**
  String get settingsQuranContinuousStart;

  /// No description provided for @settingsQuranContinuousResume.
  ///
  /// In ar, this message translates to:
  /// **'متابعة من آخر سورة'**
  String get settingsQuranContinuousResume;

  /// No description provided for @settingsQuranContinuousResumeDesc.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ من السورة التي توقفت عندها'**
  String get settingsQuranContinuousResumeDesc;

  /// No description provided for @settingsQuranContinuousFromStart.
  ///
  /// In ar, this message translates to:
  /// **'من البداية في كل مرة'**
  String get settingsQuranContinuousFromStart;

  /// No description provided for @settingsQuranContinuousFromStartDesc.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ من سورة الفاتحة عند كل تشغيل ثم بترتيب المصحف'**
  String get settingsQuranContinuousFromStartDesc;

  /// No description provided for @settingsQuranContinuousRandom.
  ///
  /// In ar, this message translates to:
  /// **'عشوائي'**
  String get settingsQuranContinuousRandom;

  /// No description provided for @settingsQuranContinuousRandomDesc.
  ///
  /// In ar, this message translates to:
  /// **'يختار سوراً عشوائية في كل مرة'**
  String get settingsQuranContinuousRandomDesc;

  /// No description provided for @settingsQuranModeSingleSurah.
  ///
  /// In ar, this message translates to:
  /// **'سورة واحدة'**
  String get settingsQuranModeSingleSurah;

  /// No description provided for @settingsQuranModeSingleSurahDesc.
  ///
  /// In ar, this message translates to:
  /// **'اختر سورة وكرّرها كما تريد'**
  String get settingsQuranModeSingleSurahDesc;

  /// No description provided for @settingsQuranModePlaylist.
  ///
  /// In ar, this message translates to:
  /// **'قائمة تلاوة'**
  String get settingsQuranModePlaylist;

  /// No description provided for @settingsQuranModePlaylistDesc.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة من السُّوَر تُتلى بالتتابع'**
  String get settingsQuranModePlaylistDesc;

  /// No description provided for @settingsQuranSelectSurah.
  ///
  /// In ar, this message translates to:
  /// **'اختر السورة'**
  String get settingsQuranSelectSurah;

  /// No description provided for @settingsQuranNoSurahSelected.
  ///
  /// In ar, this message translates to:
  /// **'لم تختر سورة بعد'**
  String get settingsQuranNoSurahSelected;

  /// No description provided for @settingsQuranEditPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'اختيار السُّوَر'**
  String get settingsQuranEditPlaylist;

  /// No description provided for @settingsQuranPlaylistEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تختر أي سورة بعد'**
  String get settingsQuranPlaylistEmpty;

  /// No description provided for @settingsQuranPlaylistCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سورة'**
  String settingsQuranPlaylistCount(Object count);

  /// No description provided for @settingsQuranRepeatCount.
  ///
  /// In ar, this message translates to:
  /// **'كم مرة تسمعها؟'**
  String get settingsQuranRepeatCount;

  /// No description provided for @settingsQuranCycleCount.
  ///
  /// In ar, this message translates to:
  /// **'كم دورة؟'**
  String get settingsQuranCycleCount;

  /// No description provided for @settingsQuranCountValue.
  ///
  /// In ar, this message translates to:
  /// **'{count}'**
  String settingsQuranCountValue(Object count);

  /// No description provided for @settingsQuranCountInfinite.
  ///
  /// In ar, this message translates to:
  /// **'بلا توقف'**
  String get settingsQuranCountInfinite;

  /// No description provided for @searchSurahHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سورة…'**
  String get searchSurahHint;

  /// No description provided for @searchReciterHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن قارئ…'**
  String get searchReciterHint;

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get searchNoResults;

  /// No description provided for @surahPickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار سورة'**
  String get surahPickerTitle;

  /// No description provided for @surahPlaylistEditorTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار السُّوَر'**
  String get surahPlaylistEditorTitle;

  /// No description provided for @surahPlaylistEditorSelectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get surahPlaylistEditorSelectAll;

  /// No description provided for @surahPlaylistEditorClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get surahPlaylistEditorClear;

  /// No description provided for @takbeeratFitrGreeting.
  ///
  /// In ar, this message translates to:
  /// **'عيد الفطر المبارك'**
  String get takbeeratFitrGreeting;

  /// No description provided for @takbeeratAdhaGreeting.
  ///
  /// In ar, this message translates to:
  /// **'عيد الأضحى المبارك'**
  String get takbeeratAdhaGreeting;

  /// No description provided for @takbeeratGenericGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أيام مباركة'**
  String get takbeeratGenericGreeting;

  /// No description provided for @takbeeratCardSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تكبيرات العيد متاحة'**
  String get takbeeratCardSubtitle;

  /// No description provided for @takbeeratButtonLabel.
  ///
  /// In ar, this message translates to:
  /// **'تكبيرات'**
  String get takbeeratButtonLabel;

  /// No description provided for @mushafLandingTitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get mushafLandingTitle;

  /// No description provided for @mushafContinueReading.
  ///
  /// In ar, this message translates to:
  /// **'متابعة القراءة'**
  String get mushafContinueReading;

  /// No description provided for @mushafOpenFromStart.
  ///
  /// In ar, this message translates to:
  /// **'افتح القرآن من البداية'**
  String get mushafOpenFromStart;

  /// No description provided for @mushafSurahIndex.
  ///
  /// In ar, this message translates to:
  /// **'فهرس السور'**
  String get mushafSurahIndex;

  /// No description provided for @mushafSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سورة...'**
  String get mushafSearchHint;

  /// No description provided for @mushafSearchEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سورة بهذا الاسم'**
  String get mushafSearchEmpty;

  /// No description provided for @mushafLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المصحف'**
  String get mushafLoadError;

  /// No description provided for @mushafPageWord.
  ///
  /// In ar, this message translates to:
  /// **'صفحة'**
  String get mushafPageWord;

  /// No description provided for @mushafJuzWord.
  ///
  /// In ar, this message translates to:
  /// **'الجزء'**
  String get mushafJuzWord;

  /// No description provided for @mushafAyahWord.
  ///
  /// In ar, this message translates to:
  /// **'الآية'**
  String get mushafAyahWord;

  /// No description provided for @mushafSurahPrefix.
  ///
  /// In ar, this message translates to:
  /// **'سورة'**
  String get mushafSurahPrefix;

  /// No description provided for @mushafAyahsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} آية'**
  String mushafAyahsCount(String count);

  /// No description provided for @mushafJumpToPage.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب لصفحة'**
  String get mushafJumpToPage;

  /// No description provided for @mushafJumpDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب إلى صفحة'**
  String get mushafJumpDialogTitle;

  /// No description provided for @mushafJumpDialogHint.
  ///
  /// In ar, this message translates to:
  /// **'١ - ٦٠٤'**
  String get mushafJumpDialogHint;

  /// No description provided for @mushafJumpDialogError.
  ///
  /// In ar, this message translates to:
  /// **'الرقم يجب أن يكون بين ١ و ٦٠٤'**
  String get mushafJumpDialogError;

  /// No description provided for @mushafJumpDialogGo.
  ///
  /// In ar, this message translates to:
  /// **'اذهب'**
  String get mushafJumpDialogGo;

  /// No description provided for @mushafSaveHere.
  ///
  /// In ar, this message translates to:
  /// **'احفظ هنا'**
  String get mushafSaveHere;

  /// No description provided for @mushafBookmarkSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ موضعك'**
  String get mushafBookmarkSaved;

  /// No description provided for @mushafReadingSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات القراءة'**
  String get mushafReadingSettings;

  /// No description provided for @mushafThemeSection.
  ///
  /// In ar, this message translates to:
  /// **'السمة'**
  String get mushafThemeSection;

  /// No description provided for @mushafThemePaper.
  ///
  /// In ar, this message translates to:
  /// **'ورقي'**
  String get mushafThemePaper;

  /// No description provided for @mushafThemeSepia.
  ///
  /// In ar, this message translates to:
  /// **'مصحف'**
  String get mushafThemeSepia;

  /// No description provided for @mushafThemeNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get mushafThemeNight;

  /// No description provided for @mushafFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم العرض'**
  String get mushafFontSize;

  /// No description provided for @mushafContinuousPlayback.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل مستمر'**
  String get mushafContinuousPlayback;

  /// No description provided for @mushafContinuousDescription.
  ///
  /// In ar, this message translates to:
  /// **'يُتلى التالي تلقائياً بعد كل آية'**
  String get mushafContinuousDescription;

  /// No description provided for @mushafReciterSection.
  ///
  /// In ar, this message translates to:
  /// **'القارئ'**
  String get mushafReciterSection;

  /// No description provided for @mushafAudioError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل الصوت — تحقّق من الإنترنت'**
  String get mushafAudioError;

  /// No description provided for @mushafPlayingPrefix.
  ///
  /// In ar, this message translates to:
  /// **'يُتلى'**
  String get mushafPlayingPrefix;

  /// No description provided for @mushafLoadingPrefix.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get mushafLoadingPrefix;

  /// No description provided for @mushafPausedPrefix.
  ///
  /// In ar, this message translates to:
  /// **'متوقّف مؤقّتاً'**
  String get mushafPausedPrefix;

  /// No description provided for @mushafPauseAudio.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقّت'**
  String get mushafPauseAudio;

  /// No description provided for @mushafResumeAudio.
  ///
  /// In ar, this message translates to:
  /// **'استئناف'**
  String get mushafResumeAudio;

  /// No description provided for @mushafStopAudio.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get mushafStopAudio;

  /// No description provided for @mushafBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get mushafBack;

  /// No description provided for @mushafIntroTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في المصحف'**
  String get mushafIntroTitle;

  /// No description provided for @mushafIntroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تعرّف على كيفية الاستخدام في لمحة سريعة'**
  String get mushafIntroSubtitle;

  /// No description provided for @mushafIntroSwipeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنقّل بين الصفحات'**
  String get mushafIntroSwipeTitle;

  /// No description provided for @mushafIntroSwipeBody.
  ///
  /// In ar, this message translates to:
  /// **'اسحب يميناً أو يساراً للانتقال بين صفحات المصحف'**
  String get mushafIntroSwipeBody;

  /// No description provided for @mushafIntroTapAyahTitle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على آية للاستماع'**
  String get mushafIntroTapAyahTitle;

  /// No description provided for @mushafIntroTapAyahBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط أي آية لتلاوتها، واضغطها مرة أخرى للإيقاف أو الاستئناف'**
  String get mushafIntroTapAyahBody;

  /// No description provided for @mushafIntroNavigateTitle.
  ///
  /// In ar, this message translates to:
  /// **'فهرس السور والقفز السريع'**
  String get mushafIntroNavigateTitle;

  /// No description provided for @mushafIntroNavigateBody.
  ///
  /// In ar, this message translates to:
  /// **'استخدم زر الفهرس للوصول للسور، وزر القفز للانتقال إلى رقم صفحة محدد'**
  String get mushafIntroNavigateBody;

  /// No description provided for @mushafIntroBookmarkTitle.
  ///
  /// In ar, this message translates to:
  /// **'حفظ موضعك تلقائياً'**
  String get mushafIntroBookmarkTitle;

  /// No description provided for @mushafIntroBookmarkBody.
  ///
  /// In ar, this message translates to:
  /// **'نحفظ موضعك تلقائياً عند الخروج، ويمكنك حفظه يدوياً من زر العلامة في الأعلى'**
  String get mushafIntroBookmarkBody;

  /// No description provided for @mushafIntroSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'خصّص قراءتك'**
  String get mushafIntroSettingsTitle;

  /// No description provided for @mushafIntroSettingsBody.
  ///
  /// In ar, this message translates to:
  /// **'غيّر السمة، حجم الخط، والقارئ من زر الإعدادات'**
  String get mushafIntroSettingsBody;

  /// No description provided for @mushafIntroCta.
  ///
  /// In ar, this message translates to:
  /// **'فهمت، لنبدأ'**
  String get mushafIntroCta;

  /// No description provided for @mushafIntroHelp.
  ///
  /// In ar, this message translates to:
  /// **'تعريف بالميزات'**
  String get mushafIntroHelp;
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
