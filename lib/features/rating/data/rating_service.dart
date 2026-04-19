import 'package:shared_preferences/shared_preferences.dart';

import '../domain/i_rating_service.dart';

/// SharedPreferences-backed implementation of [IRatingService].
/// Logic: show after 7 days of first launch, snooze 14 days on "Later",
/// snooze 30 days on "Suggest", never show again after "Rate".
class RatingService implements IRatingService {
  static const _keyFirstLaunchMs = 'rating_first_launch_ms';
  static const _keySnoozeUntilMs = 'rating_snooze_until_ms';
  static const _keyIsRated = 'rating_is_rated';

  static const int _minDaysBeforePrompt = 2;
  static const int _snoozeDays = 7;
  static const int _snoozeLongDays = 7;

  @override
  Future<void> recordFirstLaunchIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyFirstLaunchMs)) return;

    // إذا كان المستخدم يمتلك إعدادات مسبقة (مثل المدينة)، فهو مستخدم قديم يقوم بتحديث التطبيق
    final isExistingUser = prefs.getString('salah_tv_selected_city') != null;

    DateTime launchDate = DateTime.now();
    if (isExistingUser) {
      // نرجع التاريخ للوراء بمقدار يوم واحد فقط.
      // هكذا غداً سيكتمل شرط اليومين وتظهر نافذة التقييم دون إزعاج المستخدم في يوم التحديث.
      launchDate = launchDate.subtract(
        const Duration(days: _minDaysBeforePrompt - 1),
      );
    }

    await prefs.setInt(_keyFirstLaunchMs, launchDate.millisecondsSinceEpoch);
  }

  @override
  Future<bool> shouldShowDialog() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_keyIsRated) == true) return false;

    final firstLaunchMs = prefs.getInt(_keyFirstLaunchMs);
    if (firstLaunchMs == null) return false;

    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
    final daysSinceLaunch = DateTime.now().difference(firstLaunch).inDays;
    if (daysSinceLaunch < _minDaysBeforePrompt) return false;

    final snoozeUntilMs = prefs.getInt(_keySnoozeUntilMs);
    if (snoozeUntilMs != null) {
      final snoozeUntil = DateTime.fromMillisecondsSinceEpoch(snoozeUntilMs);
      if (DateTime.now().isBefore(snoozeUntil)) return false;
    }

    return true;
  }

  @override
  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsRated, true);
  }

  /// "لاحقاً" — remind after 14 days.
  @override
  Future<void> snooze() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(const Duration(days: _snoozeDays));
    await prefs.setInt(_keySnoozeUntilMs, until.millisecondsSinceEpoch);
  }

  /// "اقتراح" — remind after 30 days.
  @override
  Future<void> snoozeLong() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(const Duration(days: _snoozeLongDays));
    await prefs.setInt(_keySnoozeUntilMs, until.millisecondsSinceEpoch);
  }
}
