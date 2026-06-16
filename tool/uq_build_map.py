"""Build tool/uq_city_map.json  ({EnglishName: srcArabicForCoords})
and tool/uq_translations_add.json ({EnglishName: ArabicDisplay}) for ALL official
ummulqura cities, reusing existing English names for the 29 cities we already ship.
"""
import json

coords = {c["id"]: c for c in json.load(open("tool/uq_saudi_cities.json", encoding="utf-8"))}

# id -> (ArabicDisplay, EnglishCsvName).  English reuses our existing 29 names where
# the city already ships; otherwise a standard transliteration.
EN = {
    "1": ("الرياض", "Riyadh"), "2": ("الدرعية", "Diriyah"), "3": ("الخرج", "Al Kharj"),
    "4": ("الدوادمي", "Ad Dawadimi"), "5": ("المجمعة", "Al Majmaah"), "6": ("القويعية", "Quwaiiyah"),
    "7": ("وادي الدواسر", "Wadi Al Dawasir"), "8": ("الأفلاج", "Al Aflaj"), "9": ("الزلفي", "Az Zulfi"),
    "10": ("شقراء", "Shaqra"), "11": ("حوطة بني تميم", "Hotat Bani Tamim"),
    # id 12 (عفيف / Afif) intentionally excluded: the source 500s for this city.
    "13": ("السليل", "As Sulayyil"), "14": ("ضرما", "Dharma"), "15": ("المزاحمية", "Al Muzahimiyah"),
    "16": ("رماح", "Rumah"), "17": ("ثادق", "Thadiq"), "18": ("حريملاء", "Huraymila"),
    "19": ("الحريق", "Al Hareeq"), "20": ("الغاط", "Al Ghat"), "21": ("مكة المكرمة", "Mecca"),
    "22": ("جدة", "Jeddah"), "23": ("الطائف", "Taif"), "24": ("القنفذة", "Al Qunfudhah"),
    "25": ("الليث", "Al Lith"), "26": ("رابغ", "Rabigh"), "27": ("الجموم", "Al Jumum"),
    "28": ("خليص", "Khulais"), "29": ("الكامل", "Al Kamil"), "30": ("الخرمة", "Al Khurmah"),
    "31": ("رنية", "Ranyah"), "32": ("تربة", "Turabah"), "33": ("المدينة المنورة", "Medina"),
    "34": ("ينبع", "Yanbu"), "35": ("العلا", "Al Ula"), "36": ("المهد", "Mahd Adh Dhahab"),
    "37": ("بدر", "Al Badr"), "38": ("خيبر", "Khaybar"), "39": ("الحناكية", "Al Hanakiyah"),
    "40": ("بريدة", "Al Qassim"), "41": ("عنيزة", "Unaizah"), "42": ("الرس", "Al Rass"),
    "43": ("المذنب", "Al Midhnab"), "44": ("البكيرية", "Al Bukayriyah"), "45": ("البدائع", "Al Badaie"),
    "46": ("الأسياح", "Al Asyah"), "47": ("النبهانية", "An Nabhaniyah"), "48": ("عيون الجواء", "Uyun Al Jiwa"),
    "49": ("رياض الخبراء", "Riyadh Al Khabra"), "50": ("الشماسية", "Ash Shimasiyah"), "51": ("الدمام", "Dammam"),
    "52": ("الأحساء", "Al Ahsa"), "53": ("حفر الباطن", "Hafr Al Batin"), "54": ("الجبيل", "Jubail"),
    "55": ("القطيف", "Qatif"), "56": ("الخبر", "Khobar"), "57": ("الخفجي", "Al Khafji"),
    "58": ("رأس تنورة", "Ras Tanura"), "59": ("أبقيق", "Abqaiq"), "60": ("النعيرية", "An Nairyah"),
    "61": ("قرية العليا", "Qaryat Al Ulya"), "62": ("الخرخير", "Al Kharkhir"), "63": ("أبها", "Abha"),
    "64": ("خميس مشيط", "Khamis Mushait"), "65": ("بيشة", "Bisha"), "66": ("النماص", "An Namas"),
    "67": ("محايل", "Muhayil"), "68": ("سراة عبيدة", "Sarat Abidah"), "69": ("تثليث", "Tathlith"),
    "70": ("رجال ألمع", "Rijal Almaa"), "71": ("أحد رفيدة", "Ahad Rafidah"), "72": ("ظهران الجنوب", "Dhahran Al Janub"),
    "73": ("بلقرن", "Balqarn"), "74": ("المجاردة", "Al Majaridah"), "75": ("تبوك", "Tabuk"),
    "76": ("الوجه", "Al Wajh"), "77": ("ضباء", "Duba"), "78": ("تيماء", "Tayma"),
    "79": ("أملج", "Umluj"), "80": ("حقل", "Haql"), "81": ("حائل", "Hail"),
    "82": ("بقعاء", "Baqaa"), "83": ("الغزالة", "Al Ghazalah"), "84": ("الشنان", "Ash Shinan"),
    "85": ("عرعر", "Arar"), "86": ("رفحاء", "Rafha"), "87": ("طريف", "Turaif"),
    "88": ("جازان", "Jizan"), "89": ("صبياء", "Sabya"), "90": ("أبو عريش", "Abu Arish"),
    "91": ("صامطة", "Samitah"), "92": ("الحرث", "Al Harth"), "93": ("ضمد", "Damad"),
    "94": ("الريث", "Ar Rayth"), "95": ("بيش", "Baish"), "96": ("فرسان", "Farasan"),
    "97": ("الدائر", "Ad Dayer"), "98": ("أحد المسارحة", "Ahad Al Masarihah"), "99": ("العيدابي", "Al Idabi"),
    "100": ("العارضة", "Al Aridah"), "101": ("القياس", "Al Qiyas"), "102": ("نجران", "Najran"),
    "103": ("شرورة", "Sharurah"), "104": ("حبونا", "Habuna"), "105": ("بدر الجنوب", "Badr Al Janub"),
    "106": ("يدمة", "Yadamah"), "107": ("ثار", "Thar"), "108": ("خباش", "Khabash"),
    "109": ("الباحة", "Al Bahah"), "110": ("بلجرشي", "Baljurashi"), "111": ("المندق", "Al Mandaq"),
    "112": ("المخواة", "Al Makhwah"), "113": ("العقيق", "Al Aqiq"), "114": ("قلوة", "Qilwah"),
    "115": ("القرى", "Al Qura"), "116": ("سكاكا", "Sakaka"), "117": ("القريات", "Al Qurayyat"),
    "118": ("دومة الجندل", "Dumat Al Jandal"),
}

# Legacy cities we already ship that have no distinct official entry -> nearest official id.
LEGACY = {
    "Yanbu Al Sinaiyah": ("ينبع الصناعية", "34"),  # = Yanbu
    "Rahimah":           ("رحيمة", "58"),           # Ras Tanura
    "Thuwal":            ("ثول", "26"),             # Rabigh (coastal, nearest)
    "Safaniyah":         ("السفانية", "57"),        # Khafji
    "Tanumah":           ("تنومة", "66"),           # An Namas (Asir highland)
}

city_map = {}   # English -> site Arabic name used for coords
trans = {}      # English -> Arabic display
for cid, (ar, en) in EN.items():
    c = coords.get(cid)
    if not c:
        print(f"  WARN id {cid} ({en}) has no harvested coords")
        continue
    city_map[en] = c["ar"]          # use the harvested Arabic key for coord lookup
    trans[en] = ar
for en, (ar, ref_id) in LEGACY.items():
    c = coords.get(ref_id)
    if not c:
        print(f"  WARN legacy {en} ref id {ref_id} missing"); continue
    city_map[en] = c["ar"]
    trans[en] = ar

json.dump(city_map, open("tool/uq_city_map.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
json.dump(trans, open("tool/uq_translations_add.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"city_map: {len(city_map)} cities  |  translations: {len(trans)}")
print("missing-coords cities:", [en for cid,(ar,en) in EN.items() if cid not in coords])
