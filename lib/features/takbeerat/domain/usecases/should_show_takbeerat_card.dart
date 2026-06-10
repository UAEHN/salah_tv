import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/eid_type.dart';
import '../entities/eid_visibility.dart';
import '../entities/hijri_snapshot.dart';
import '../entities/takbeerat_config.dart';
import '../i_hijri_date_provider.dart';
import '../i_takbeerat_config_repository.dart';

/// Single source of truth for "should the Eid Takbeerat home card show now?".
///
/// Decision order (first match wins):
///   1. `isFeatureEnabled == false` → hidden (master kill switch).
///   2. `forceHide == true`         → hidden (emergency override).
///   3. `forceShow == true`         → showing (remote override).
///   4. inside a natural Eid window → showing, with [EidType] tagged.
///   5. otherwise                   → hidden.
class ShouldShowTakbeeratCard {
  ShouldShowTakbeeratCard({
    required ITakbeeratConfigRepository configRepo,
    required IHijriDateProvider hijri,
  }) : _configRepo = configRepo,
       _hijri = hijri;

  final ITakbeeratConfigRepository _configRepo;
  final IHijriDateProvider _hijri;

  Future<Either<Failure, EidVisibility>> call(DateTime now) async {
    final result = await _configRepo.fetchConfig();
    return result.map((config) => _decide(config, now));
  }

  EidVisibility _decide(TakbeeratConfig cfg, DateTime now) {
    if (!cfg.isFeatureEnabled) return EidVisibility.hidden();
    if (cfg.hasForceHide) return EidVisibility.hidden();
    if (cfg.hasForceShow) {
      return EidVisibility.showing(eid: null, isForcedByRemote: true);
    }
    final hijri = _hijri.fromGregorian(now);
    final activeEid = _detectActiveEid(hijri, cfg);
    if (activeEid == null) return EidVisibility.hidden();
    return EidVisibility.showing(eid: activeEid);
  }

  /// Determines whether [d] falls inside any configured Eid window.
  /// Uses [HijriSnapshot.lengthOfMonth] for the Ramadan tail so the
  /// "show in last N days of Ramadan" rule works for both 29- and 30-day
  /// Ramadans.
  EidType? _detectActiveEid(HijriSnapshot d, TakbeeratConfig cfg) {
    // عيد الفطر: آخر أيام رمضان + أول أيام شوال
    if (d.month == _ramadan &&
        d.day > d.lengthOfMonth - cfg.fitrStartOffsetDays) {
      return EidType.fitr;
    }
    if (d.month == _shawwal && d.day <= 1 + cfg.fitrEndOffsetDays) {
      return EidType.fitr;
    }
    // عيد الأضحى: حول ١٠ ذو الحجة (يشمل عرفة + التروية + أيام التشريق)
    if (d.month == _dhulHijjah) {
      final start = 10 - cfg.adhaStartOffsetDays;
      final end = 10 + cfg.adhaEndOffsetDays;
      if (d.day >= start && d.day <= end) return EidType.adha;
    }
    return null;
  }

  static const int _ramadan = 9;
  static const int _shawwal = 10;
  static const int _dhulHijjah = 12;
}
