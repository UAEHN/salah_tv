import '../domain/entities/upcoming_occasion.dart';

/// Static list of well-known Hijri occasions (mobile-only, in-memory).
/// Sorted by Hijri month/day. Adding a new entry requires:
///   1. an `id` and a localization key in `app_*.arb`
///   2. the Hijri month/day at which it falls
const List<UpcomingOccasion> kIslamicOccasionsCatalog = [
  // — Muharram (1) —
  UpcomingOccasion(
    id: 'hijri_new_year',
    labelKey: 'occasionHijriNewYear',
    hijriMonth: 1,
    hijriDay: 1,
    daysUntil: 0,
  ),
  UpcomingOccasion(
    id: 'ashura',
    labelKey: 'occasionAshura',
    hijriMonth: 1,
    hijriDay: 10,
    daysUntil: 0,
  ),
  // — Rabi' al-Awwal (3) —
  UpcomingOccasion(
    id: 'mawlid',
    labelKey: 'occasionMawlid',
    hijriMonth: 3,
    hijriDay: 12,
    daysUntil: 0,
  ),
  // — Rajab (7) —
  UpcomingOccasion(
    id: 'isra_miraj',
    labelKey: 'occasionIsraMiraj',
    hijriMonth: 7,
    hijriDay: 27,
    daysUntil: 0,
  ),
  // — Sha'ban (8) —
  UpcomingOccasion(
    id: 'mid_shaban',
    labelKey: 'occasionMidShaban',
    hijriMonth: 8,
    hijriDay: 15,
    daysUntil: 0,
  ),
  // — Ramadan (9) —
  UpcomingOccasion(
    id: 'ramadan_start',
    labelKey: 'occasionRamadanStart',
    hijriMonth: 9,
    hijriDay: 1,
    daysUntil: 0,
  ),
  UpcomingOccasion(
    id: 'laylat_qadr',
    labelKey: 'occasionLaylatQadr',
    hijriMonth: 9,
    hijriDay: 27,
    daysUntil: 0,
  ),
  // — Shawwal (10) —
  UpcomingOccasion(
    id: 'eid_fitr',
    labelKey: 'occasionEidFitr',
    hijriMonth: 10,
    hijriDay: 1,
    daysUntil: 0,
  ),
  // — Dhu al-Hijjah (12) —
  UpcomingOccasion(
    id: 'arafah',
    labelKey: 'occasionArafah',
    hijriMonth: 12,
    hijriDay: 9,
    daysUntil: 0,
  ),
  UpcomingOccasion(
    id: 'eid_adha',
    labelKey: 'occasionEidAdha',
    hijriMonth: 12,
    hijriDay: 10,
    daysUntil: 0,
  ),
];
