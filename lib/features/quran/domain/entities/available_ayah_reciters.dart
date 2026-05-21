import 'ayah_reciter.dart';

/// Canonical list of per-ayah reciters available via everyayah.com.
/// The first entry is the default surfaced to new users.
///
/// Folder names must match exactly the ones hosted at
/// `https://www.everyayah.com/data/<urlSegment>/` — verified before
/// adding new entries.
const List<AyahReciter> kAvailableAyahReciters = [
  AyahReciter(
    id: 'husary_muallim',
    nameAr: 'الحصري - معلِّم',
    urlSegment: 'Husary_Muallim_128kbps',
  ),
  AyahReciter(
    id: 'abdulbasit_murattal',
    nameAr: 'عبد الباسط عبد الصمد - مرتَّل',
    urlSegment: 'Abdul_Basit_Murattal_64kbps',
  ),
  AyahReciter(
    id: 'alafasy',
    nameAr: 'مشاري راشد العفاسي',
    urlSegment: 'Alafasy_128kbps',
  ),
  AyahReciter(
    id: 'ghamadi',
    nameAr: 'سعد الغامدي',
    urlSegment: 'Ghamadi_40kbps',
  ),
  AyahReciter(
    id: 'sudais',
    nameAr: 'عبد الرحمن السديس',
    urlSegment: 'Abdurrahmaan_As-Sudais_64kbps',
  ),
  AyahReciter(
    id: 'shuraim',
    nameAr: 'سعود الشريم',
    urlSegment: 'Saood_ash-Shuraym_64kbps',
  ),
  AyahReciter(
    id: 'almuaiqly',
    nameAr: 'ماهر المعيقلي',
    urlSegment: 'Maher_AlMuaiqly_64kbps',
  ),
  AyahReciter(
    id: 'minshawy_murattal',
    nameAr: 'محمد المنشاوي - مرتَّل',
    urlSegment: 'Minshawy_Murattal_128kbps',
  ),
];

/// Resolves a reciter by id, falling back to the default when not found
/// (e.g. an unknown id loaded from older SharedPreferences).
AyahReciter resolveReciter(String? id) {
  if (id == null) return kAvailableAyahReciters.first;
  for (final r in kAvailableAyahReciters) {
    if (r.id == id) return r;
  }
  return kAvailableAyahReciters.first;
}
