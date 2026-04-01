// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'غسق';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get localeComma => '،';

  @override
  String get commonEnabled => 'مفعّل';

  @override
  String get commonDisabled => 'معطّل';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonSaveChanges => 'حفظ التغييرات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navAdhkar => 'الأذكار';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navTasbih => 'التسبيح';

  @override
  String get adhkarNotAvailableOnTv => 'الأذكار غير متوفرة على أجهزة التلفاز';

  @override
  String adhkarCompletedCategory(Object categoryName) {
    return 'أنهيت $categoryName';
  }

  @override
  String get adhkarMayAllahAccept => 'تقبل الله منك';

  @override
  String get adhkarBackToCategories => 'العودة إلى التصنيفات';

  @override
  String adhkarCountLabel(int count) {
    return '$count ذكر';
  }

  @override
  String get adhkarMorningSession => 'أذكار الصباح';

  @override
  String get adhkarEveningSession => 'أذكار المساء';

  @override
  String get tasbihEntrySummary => 'ابدأ التسبيح اليومي';

  @override
  String get tasbihPhraseSubhanAllah => 'سبحان الله';

  @override
  String get tasbihPhraseAlhamdulillah => 'الحمد لله';

  @override
  String get tasbihPhraseAllahuAkbar => 'الله أكبر';

  @override
  String get tasbihPhraseLaIlahaIllallah => 'لا إله إلا الله';

  @override
  String get tasbihCompletedMessage => 'تم الإنجاز';

  @override
  String get tasbihSwipeHint => 'اسحب للتبديل بين الأذكار';

  @override
  String get tasbihResetTooltip => 'إعادة العداد';

  @override
  String get duaAfterAdhanTitle => 'دعاء بعد الأذان';

  @override
  String get duaAfterAdhanText =>
      'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ.';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get nextPrayerLabel => 'الوقت المتبقي على أذان';

  @override
  String get nextPrayerActiveLabel => 'الصلاة القادمة';

  @override
  String countdownNextPrayer(Object prayerName) {
    return 'باقي على صلاة $prayerName';
  }

  @override
  String countdownToIqama(Object prayerName) {
    return 'باقي على إقامة $prayerName';
  }

  @override
  String iqamaAfterPrayer(Object prayerName) {
    return 'إقامة صلاة $prayerName بعد';
  }

  @override
  String get ongoingNow => 'جارٍ الآن';

  @override
  String get adhanNowTitle => 'حان الآن موعد';

  @override
  String adhanPrayerTitle(Object prayerName) {
    return 'أذان $prayerName';
  }

  @override
  String get skipAdhanHint => 'اضغط OK لتخطي الأذان';

  @override
  String get iqamaNowTitle => 'حان موعد صلاة';

  @override
  String get iqamaLabel => 'الإقامة';

  @override
  String get noPrayerDataToday => 'لا توجد بيانات لهذا اليوم';

  @override
  String get noPrayerDataForDate => 'لا توجد بيانات لهذا التاريخ';

  @override
  String get checkCsvInSettings => 'تحقق من ملف CSV في الإعدادات';

  @override
  String get pressOkForSettings => 'اضغط OK للإعدادات';

  @override
  String get backToToday => 'العودة إلى اليوم';

  @override
  String get notificationReminderTitle => 'تذكير';

  @override
  String get notificationIqamaTitle => 'الإقامة';

  @override
  String notificationAdhanBody(Object prayerName) {
    return 'حان وقت $prayerName';
  }

  @override
  String notificationPreAdhanBody(Object prayerName, Object minutes) {
    return '$prayerName بعد $minutes دقيقة';
  }

  @override
  String notificationPreIqamaBody(Object prayerName, Object minutes) {
    return 'إقامة $prayerName بعد $minutes دقيقة';
  }

  @override
  String notificationIqamaBody(Object prayerName) {
    return 'حان وقت إقامة $prayerName';
  }

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTimeFormat => 'صيغة الوقت';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsOther => 'أخرى';

  @override
  String get settings24HourFormat => 'صيغة 24 ساعة';

  @override
  String get settings24HourEnabled => 'نظام 24 ساعة';

  @override
  String get settings12HourEnabled => 'نظام 12 ساعة';

  @override
  String get settings24HourLabel => '24 ساعة';

  @override
  String get settings12HourLabel => '12 ساعة';

  @override
  String get settingsCustomizeAppearance => 'تخصيص المظهر';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsLightMode => 'الوضع الفاتح';

  @override
  String get settingsDarkModeLabel => 'الوضع الليلي';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsLocationSection => 'الموقع';

  @override
  String get settingsCountryAndCity => 'الدولة والمدينة';

  @override
  String get settingsNotificationsSection => 'التنبيهات';

  @override
  String get settingsNotificationSettings => 'إعدادات التنبيهات';

  @override
  String get settingsCalculationSection => 'الحساب';

  @override
  String get settingsCalculationMethodLabel => 'طريقة الحساب';

  @override
  String get settingsMadhabLabel => 'المذهب الفقهي';

  @override
  String get settingsAdjustPrayerTimes => 'تعديل أوقات الأذان والإقامة';

  @override
  String get settingsGeneralSettings => 'إعدادات عامة';

  @override
  String get settingsPrayerAlerts => 'تنبيهات الصلوات';

  @override
  String get settingsAdhanSoundLabel => 'صوت الأذان';

  @override
  String get settingsPreAdhanReminder => 'تذكير قبل الأذان';

  @override
  String get settingsAdhanAlert => 'تنبيه الأذان';

  @override
  String get settingsPreIqamaReminder => 'تذكير قبل الإقامة';

  @override
  String get settingsIqamaAlert => 'تنبيه الإقامة';

  @override
  String get settingsPreAdhanDuration => 'مدة التذكير قبل الأذان';

  @override
  String get settingsPreIqamaDuration => 'مدة التذكير قبل الإقامة';

  @override
  String settingsBeforeMinutes(Object minutes) {
    return 'قبل $minutes دقيقة';
  }

  @override
  String settingsDurationMinutes(Object minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get settingsAdjustTimes => 'تعديل الأوقات';

  @override
  String get settingsAdjustAdhanTimeTitle => 'ضبط وقت الأذان';

  @override
  String get settingsAdjustAdhanTimeSubtitle =>
      'تقديم أو تأخير الأذان (−30 إلى +30 دقيقة)';

  @override
  String get settingsIqamaDelayTitle => 'تأخير الإقامة';

  @override
  String get settingsIqamaDelaySubtitle =>
      'عدد الدقائق بعد الأذان (0 إلى 60 دقيقة)';

  @override
  String get settingsMinuteShort => 'د';

  @override
  String get settingsMinuteUnit => 'دقيقة';

  @override
  String get settingsMadhabAffectsAsrNote =>
      'يؤثر على وقت العصر في الأوقات المحسوبة (GPS) فقط';

  @override
  String get settingsHanafiAsrLaterNote =>
      'المذهب الحنفي يُؤخّر وقت العصر قليلاً';

  @override
  String get madhabShafi => 'الشافعي';

  @override
  String get madhabHanafi => 'الحنفي';

  @override
  String get madhabShafiFamily => 'الشافعي / المالكي / الحنبلي';

  @override
  String get settingsChooseAdhanSound => 'اختر صوت الأذان';

  @override
  String get settingsDetectingLocation => 'جارِ تحديد الموقع...';

  @override
  String get settingsDetectMyLocation => 'تحديد موقعي تلقائياً';

  @override
  String get settingsNoMatchingCountries => 'لا توجد دول مطابقة';

  @override
  String get settingsNoMatchingCities => 'لا توجد مدن مطابقة';

  @override
  String get settingsSelectCountry => 'اختر الدولة';

  @override
  String get settingsSelectCity => 'اختر المدينة';

  @override
  String get settingsSearchCountry => 'ابحث عن دولة';

  @override
  String get settingsSearchCity => 'ابحث عن مدينة';

  @override
  String get settingsMethodAffectsGpsOnly =>
      'تؤثر على الأوقات المحسوبة (GPS) فقط';

  @override
  String get settingsNotificationsEnabled => 'الإشعارات مفعّلة';

  @override
  String get settingsNotificationsDisabled => 'الإشعارات معطّلة';

  @override
  String get settingsCategoryLocation => 'الموقع';

  @override
  String get settingsCategoryLocationSubtitle => 'الدولة والمدينة';

  @override
  String get settingsCategoryQuran => 'القرآن الكريم';

  @override
  String get settingsCategoryQuranSubtitle => 'بث القرآن في الخلفية';

  @override
  String get settingsCategoryAdhan => 'الأذان';

  @override
  String get settingsCategoryAdhanSubtitle => 'صوت الأذان والتشغيل التلقائي';

  @override
  String get settingsCategoryAdhanOffsets => 'تعديل أوقات الأذان';

  @override
  String get settingsCategoryAdhanOffsetsSubtitle => 'ضبط أوقات الأذان';

  @override
  String get settingsCategoryIqama => 'تعديل أوقات الإقامة';

  @override
  String get settingsCategoryIqamaSubtitle => 'أوقات الإقامة بعد الأذان';

  @override
  String get settingsCategoryAppearance => 'المظهر';

  @override
  String get settingsCategoryAppearanceSubtitle => 'الخط والألوان والتصميم';

  @override
  String get settingsCategoryAdhkar => 'الأذكار';

  @override
  String get settingsCategoryAdhkarSubtitle => 'أذكار الصباح والمساء';

  @override
  String get settingsFont => 'الخط';

  @override
  String get settingsThemeColor => 'لون القالب';

  @override
  String get settingsLayoutDesign => 'تصميم الواجهة';

  @override
  String get settingsClockType => 'نوع الساعة';

  @override
  String get layoutModern => 'حديث';

  @override
  String get layoutClassic => 'كلاسيكي';

  @override
  String get clockDigital => 'رقمي';

  @override
  String get clockAnalog => 'تناظري';

  @override
  String get fontCairo => 'كايرو';

  @override
  String get fontBeiruti => 'بيروتي';

  @override
  String get fontKufi => 'كوفي';

  @override
  String get fontRubik => 'روبيك';

  @override
  String get fontInter => 'Inter';

  @override
  String get themeGreen => 'زمردي';

  @override
  String get themeTeal => 'فيروزي';

  @override
  String get themeGold => 'ذهبي';

  @override
  String get themeBlue => 'ياقوتي';

  @override
  String get themePurple => 'بنفسجي';

  @override
  String get settingsAutoPlayAdhan => 'تشغيل الأذان تلقائياً:';

  @override
  String get settingsChangeAdhan => 'تغيير الأذان';

  @override
  String get settingsQuranInBackground => 'تشغيل القرآن في الخلفية:';

  @override
  String get settingsNoReciterSelected => 'لم يتم اختيار قارئ';

  @override
  String get settingsChangeReciter => 'تغيير القارئ';

  @override
  String get settingsInternetRequiredForQuran =>
      'يتطلب اتصالاً بالإنترنت لتحميل قائمة القراء وتشغيل القرآن.';

  @override
  String get settingsMorningEveningAdhkar => 'أذكار الصباح والمساء:';

  @override
  String get settingsAdhkarScheduleNote =>
      'أذكار الصباح: تظهر بعد الفجر حتى الساعة 10:00 صباحاً. أذكار المساء: تظهر بعد العصر وتنتهي قبل أذان المغرب بـ 5 دقائق. تظهر مرة واحدة في اليوم، وتُوقف مؤقتاً أثناء الأذان والإقامة.';

  @override
  String get settingsNoCitySelected => 'لم يتم اختيار مدينة';

  @override
  String get settingsChangeCity => 'تغيير المدينة';

  @override
  String get settingsChangeCountry => 'تغيير الدولة';

  @override
  String get settingsCloseApp => 'إغلاق التطبيق';

  @override
  String get settingsSelectReciter => 'اختر القارئ';

  @override
  String get settingsFailedToLoadReciters =>
      'تعذّر تحميل القائمة.\nتحقق من الاتصال بالإنترنت.';

  @override
  String get settingsLoadingReciters => 'جاري تحميل القراء...';

  @override
  String get adhanSound1 => 'أذان 1';

  @override
  String get adhanSound2 => 'أذان 2';

  @override
  String get adhanSoundAliMulla => 'الشيخ علي ملا';

  @override
  String get adhanSoundAbdulbasit => 'الشيخ عبدالباسط عبدالصمد';

  @override
  String get adhanSoundAqsa => 'أذان المسجد الأقصى';

  @override
  String get qiblaPermissionDeniedTitle => 'الموقع مرفوض';

  @override
  String get qiblaPermissionDeniedSubtitle =>
      'يرجى السماح بالوصول إلى الموقع من الإعدادات';

  @override
  String get qiblaGpsDisabledTitle => 'الـ GPS معطّل';

  @override
  String get qiblaGpsDisabledSubtitle => 'يرجى تفعيل خدمة الموقع';

  @override
  String get qiblaNotAvailableOnTv => 'القبلة غير متوفرة على أجهزة التلفاز';

  @override
  String get qiblaAlignedStatus => 'أنت تشير باتجاه القبلة';

  @override
  String get qiblaFindStatus => 'اتجه نحو القبلة';

  @override
  String get qiblaAlignedSub => 'ALIGNED WITH KAABA';

  @override
  String get qiblaFindSub => 'FIND THE KAABA';

  @override
  String get qiblaDistanceToKaaba => 'المسافة للكعبة';

  @override
  String get qiblaDeviation => 'الانحراف';

  @override
  String get unitKm => 'كم';

  @override
  String get unitDegree => 'درجة';

  @override
  String get weekdayMonday => 'الاثنين';

  @override
  String get weekdayTuesday => 'الثلاثاء';

  @override
  String get weekdayWednesday => 'الأربعاء';

  @override
  String get weekdayThursday => 'الخميس';

  @override
  String get weekdayFriday => 'الجمعة';

  @override
  String get weekdaySaturday => 'السبت';

  @override
  String get weekdaySunday => 'الأحد';

  @override
  String get gregorianMonthJanuary => 'يناير';

  @override
  String get gregorianMonthFebruary => 'فبراير';

  @override
  String get gregorianMonthMarch => 'مارس';

  @override
  String get gregorianMonthApril => 'أبريل';

  @override
  String get gregorianMonthMay => 'مايو';

  @override
  String get gregorianMonthJune => 'يونيو';

  @override
  String get gregorianMonthJuly => 'يوليو';

  @override
  String get gregorianMonthAugust => 'أغسطس';

  @override
  String get gregorianMonthSeptember => 'سبتمبر';

  @override
  String get gregorianMonthOctober => 'أكتوبر';

  @override
  String get gregorianMonthNovember => 'نوفمبر';

  @override
  String get gregorianMonthDecember => 'ديسمبر';

  @override
  String get hijriMonthMuharram => 'مُحَرَّم';

  @override
  String get hijriMonthSafar => 'صَفَر';

  @override
  String get hijriMonthRabiAlAwwal => 'رَبِيع الأَوَّل';

  @override
  String get hijriMonthRabiAlThani => 'رَبِيع الثَّانِي';

  @override
  String get hijriMonthJumadaAlAwwal => 'جُمَادَى الأُولَى';

  @override
  String get hijriMonthJumadaAlAkhirah => 'جُمَادَى الآخِرَة';

  @override
  String get hijriMonthRajab => 'رَجَب';

  @override
  String get hijriMonthShaban => 'شَعْبَان';

  @override
  String get hijriMonthRamadan => 'رَمَضَان';

  @override
  String get hijriMonthShawwal => 'شَوَّال';

  @override
  String get hijriMonthDhuAlQadah => 'ذُو القَعْدَة';

  @override
  String get hijriMonthDhuAlHijjah => 'ذُو الحِجَّة';

  @override
  String get hijriYearSuffix => 'هـ';

  @override
  String get gregorianYearSuffix => 'م';

  @override
  String get calcMethodMuslimWorldLeague => 'رابطة العالم الإسلامي';

  @override
  String get calcMethodEgyptian => 'الهيئة المصرية العامة للمساحة';

  @override
  String get calcMethodKarachi => 'جامعة العلوم الإسلامية، كراتشي';

  @override
  String get calcMethodUmmAlQura => 'أم القرى';

  @override
  String get calcMethodDubai => 'دبي';

  @override
  String get calcMethodQatar => 'قطر';

  @override
  String get calcMethodKuwait => 'الكويت';

  @override
  String get calcMethodMorocco => 'المغرب';

  @override
  String get calcMethodSingapore => 'سنغافورة';

  @override
  String get calcMethodTehran => 'طهران';

  @override
  String get calcMethodTurkiye => 'تركيا (ديانت)';

  @override
  String get calcMethodNorthAmerica => 'أمريكا الشمالية (ISNA)';

  @override
  String get calcMethodMoonsightingCommittee => 'لجنة رؤية الهلال';

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
  String get fontPreviewSample => 'أبجد هوز';
}
