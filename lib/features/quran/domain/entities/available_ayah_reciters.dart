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
    nameEn: 'Mahmoud Khalil Al-Husary (Teacher)',
    urlSegment: 'Husary_Muallim_128kbps',
  ),
  AyahReciter(
    id: 'abdulbasit_murattal',
    nameAr: 'عبد الباسط عبد الصمد - مرتَّل',
    nameEn: 'Abdul Basit Abdus Samad (Murattal)',
    urlSegment: 'Abdul_Basit_Murattal_64kbps',
  ),
  AyahReciter(
    id: 'alafasy',
    nameAr: 'مشاري راشد العفاسي',
    nameEn: 'Mishary Rashid Alafasy',
    urlSegment: 'Alafasy_128kbps',
  ),
  AyahReciter(
    id: 'ghamadi',
    nameAr: 'سعد الغامدي',
    nameEn: 'Saad Al-Ghamdi',
    urlSegment: 'Ghamadi_40kbps',
  ),
  AyahReciter(
    id: 'sudais',
    nameAr: 'عبد الرحمن السديس',
    nameEn: 'Abdul Rahman Al-Sudais',
    urlSegment: 'Abdurrahmaan_As-Sudais_64kbps',
  ),
  AyahReciter(
    id: 'shuraim',
    nameAr: 'سعود الشريم',
    nameEn: 'Saud Al-Shuraim',
    urlSegment: 'Saood_ash-Shuraym_64kbps',
  ),
  AyahReciter(
    id: 'almuaiqly',
    nameAr: 'ماهر المعيقلي',
    nameEn: 'Maher Al-Muaiqly',
    urlSegment: 'Maher_AlMuaiqly_64kbps',
  ),
  AyahReciter(
    id: 'minshawy_murattal',
    nameAr: 'محمد المنشاوي - مرتَّل',
    nameEn: 'Mohamed Siddiq El-Minshawi (Murattal)',
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
