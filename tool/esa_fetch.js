/**
 * esa_fetch.js — Fetch Egypt prayer times from esa.gov.eg
 *
 * HOW TO USE:
 *   1. Open https://www.esa.gov.eg/monthlymwaket.aspx in Chrome
 *   2. Open DevTools (F12) → Console tab
 *   3. Paste this entire script and press Enter
 *   4. Wait for it to finish (progress shown in console, ~5-15 min)
 *   5. A CSV file will download automatically
 *
 * OUTPUT FILE: egypt_esa_YYYY_m1_m12.csv  (or whatever months you configure)
 * Then run:  dart run tool/csv_to_sqlite.dart
 *
 * APPROACH: Direct POST requests (no page reloads, no DOM manipulation).
 * Reads viewstate from the current page and updates it from each response.
 */

(async () => {
  // ── Config ────────────────────────────────────────────────────────────────
  const YEAR   = 2026;
  const MONTHS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]; // change as needed
  const PAGE   = 'https://www.esa.gov.eg/monthlymwaket.aspx';

  // Arabic dropdown value → English DB city name.
  // Cities not listed here will use their Arabic name as-is.
  const CITY_MAP = {
    'القـاهـرة':                 'Cairo',
    'الأسكندرية':                'Alexandria',
    'طنطــا':                    'Tanta',
    'المنصورة':                  'Mansoura',
    'الزقـازيق':                 'Zagazig',
    'أسيــوط':                   'Assiut',
    'سـوهاج':                    'Sohag',
    'بنى سويف':                  'Beni Suef',
    'المنـيـا':                  'Minya',
    'قـــنا':                    'Qena',
    'أســوان':                   'Aswan',
    'مطـروح':                    'Marsa Matruh',
    'الغردقـة':                  'Hurghada',
    'الخارجـة':                  'El-Kharga',
    'الإسماعيلية':               'Ismailia',
    'دميـاط':                    'Damietta',
    'السـلوم':                   'Al-Salloum',
    'نويـبع':                    'Nuweiba',
    'حلايــب':                   'Halayeb',
    'شرم الشيخ':                 'Sharm El-Sheikh',
    'الفـيــوم':                 'Fayoum',
    '6أكتـوبر':                  '6th of October City',
    'كفر الشيخ':                 'Kafr El-Sheikh',
    'الحامول':                   'El-Hamoul',
    'بلطيم':                     'Baltim',
    'طابا':                      'Taba',
    'راس سدر':                   'Ras Sidr',
    'الطور':                     'El-Tor',
    'دهب':                       'Dahab',
    'ابوزنيمة':                  'Abu Zenima',
    'راس غارب':                  'Ras Gharib',
    'القصير':                    'El-Quseir',
    'برنيس':                     'Berenice',
    'سفاجة':                     'Safaga',
    'مرسى علم':                  'Marsa Alam',
    'شلاتين':                    'Shalatin',
    'سيدى برانى':                'Sidi Barani',
    'الضبعة':                    'El-Dabaa',
    'العلمين':                   'El-Alamein',
    'واحة سيوة':                 'Siwa',
    'موط (الداخلة )':            'Mut (Dakhla)',
    'الفرافرة':                  'El-Farafra',
    'البويطى':                   'El-Bohaiwait',
    'باريس':                     'Paris (Egypt)',
    'المحلة الكبرى':             'El-Mahalla El-Kubra',
    'الحمام':                    'El-Hamam',
    'نجع حمادى':                 'Nag Hammadi',
    'بورسعيـد':                  'Port Said',
    'السـويس':                   'Suez',
    'العريـش':                   'El-Arish',
    'دمنـهـور':                  'Damanhour',
    'ادفو':                      'Edfu',
    'اسنا':                      'Esna',
    'الأقصر':                    'Luxor',
    'القاهرة الجديدة':           'New Cairo',
    'توشكى':                     'Toshka',
    'الدلنجات':                  'El-Delenjat',
    'كاترين':                    'Saint Catherine',
    'السادات':                   'Sadat City',
    'مدينة 15 مايو':             'May 15 City',
    'الصالحية الجديدة':          'El-Salhia El-Jadida',
    'العاشر من رمضان':           'Tenth of Ramadan',
    'العاصمة الادارية الجديدة':  'New Administrative Capital',
    'العبور':                    'El-Obour',
    'الفشن الجديدة':             'El-Fashn El-Jadida',
    'المنصورة الجديدة':          'New Mansoura',
    'النوبارية الجديدة':         'El-Noubaria El-Jadida',
    'بدر':                       'Badr',
    'بنى مزار الجديدة':          'Beni Mazar El-Jadida',
    'بورسعيد الجديدة سلام':      'New Port Said Salam',
    'بئر العبد الجديدة':         'Bir El-Abd El-Jadida',
    'توشكى الجديدة':             'New Toshka',
    'حدائق العاصمة':             'Capital Gardens',
    'رشيد الجديدة':              'New Rosetta',
    'رفح الجديدة':               'New Rafah',
    'سفنكس الجديدة':             'New Sphinx',
    'شرق العوينات':              'Sharq El-Owainat',
    'غرب النوبارية':             'West Noubaria',
    'منوف':                      'Menouf',
    'ديرب نجم':                  'Dairb Nigm',
    'ابو تشت':                   'Abu Teej',
    'سمالوط':                    'Samalout',
  };

  // ── Helpers ───────────────────────────────────────────────────────────────

  // Parse Arabic AM/PM time "4:55 ص" or "12:7 م" → "HH:MM" (24-hour)
  function parseArabicTime(raw) {
    if (!raw) return null;
    const isAm = raw.includes('ص'); // صباحاً = morning (AM)
    const isPm = raw.includes('م'); // مساءً  = evening (PM)
    const m = raw.match(/(\d{1,2}):(\d{1,2})/);
    if (!m) return null;
    let h = parseInt(m[1], 10);
    const min = m[2].padStart(2, '0');
    if (isPm && h !== 12) h += 12;
    if (isAm && h === 12) h = 0;
    return `${h.toString().padStart(2, '0')}:${min}`;
  }

  // Convert "YYYY-MM-DD" → "dd/MM/YYYY"
  function parseDate(iso) {
    const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})/);
    return m ? `${m[3]}/${m[2]}/${m[1]}` : null;
  }

  // Extract prayer times table from parsed HTML document
  function extractRows(doc, cityName) {
    const table = doc.getElementById('placeholder1_GridView1');
    if (!table) return [];
    const result = [];
    for (const row of Array.from(table.querySelectorAll('tr')).slice(1)) {
      const cells = Array.from(row.querySelectorAll('td')).map(c => c.textContent.trim());
      if (cells.length < 9) continue;
      // cols: [city, gregorian, hijri, fajr, sunrise, dhuhr, asr, maghrib, isha]
      const date    = parseDate(cells[1]);
      const fajr    = parseArabicTime(cells[3]);
      const sunrise = parseArabicTime(cells[4]);
      const dhuhr   = parseArabicTime(cells[5]);
      const asr     = parseArabicTime(cells[6]);
      const maghrib = parseArabicTime(cells[7]);
      const isha    = parseArabicTime(cells[8]);
      if (date && fajr && sunrise && dhuhr && asr && maghrib && isha) {
        result.push(`${cityName},${date},${fajr},${sunrise},${dhuhr},${asr},${maghrib},${isha}`);
      }
    }
    return result;
  }

  // ── Form state (viewstate updates from each response) ─────────────────────

  const state = {
    viewState:       document.querySelector('input[name="__VIEWSTATE"]')?.value       || '',
    viewStateGen:    document.querySelector('input[name="__VIEWSTATEGENERATOR"]')?.value || '',
    eventValidation: document.querySelector('input[name="__EVENTVALIDATION"]')?.value || '',
  };

  function updateState(doc) {
    const vs = doc.querySelector('input[name="__VIEWSTATE"]')?.value;
    if (vs) {
      state.viewState       = vs;
      state.viewStateGen    = doc.querySelector('input[name="__VIEWSTATEGENERATOR"]')?.value || state.viewStateGen;
      state.eventValidation = doc.querySelector('input[name="__EVENTVALIDATION"]')?.value    || state.eventValidation;
    }
  }

  // POST for a specific city + month, return parsed doc
  async function fetchPage(arabicCity, month) {
    const body = new URLSearchParams({
      '__EVENTTARGET':    'ctl00$placeholder1$DropDownList2',
      '__EVENTARGUMENT':  '',
      '__VIEWSTATE':       state.viewState,
      '__VIEWSTATEGENERATOR': state.viewStateGen,
      '__EVENTVALIDATION': state.eventValidation,
      'ctl00$placeholder1$DropDownList1': arabicCity,
      'ctl00$placeholder1$DropDownList2': String(month),
    });
    const resp = await fetch(PAGE, {
      method:  'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body:    body.toString(),
    });
    const html = await resp.text();
    const doc = new DOMParser().parseFromString(html, 'text/html');
    updateState(doc);
    return doc;
  }

  // ── Main loop ─────────────────────────────────────────────────────────────

  const cities = Array.from(
    document.getElementById('placeholder1_DropDownList1').options
  ).slice(1).map(o => o.value); // skip "كل المدن" (all cities)

  const rows   = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const errors = [];
  let total    = 0;

  console.log(`[esa_fetch] Starting: ${cities.length} cities × ${MONTHS.length} months`);

  for (let ci = 0; ci < cities.length; ci++) {
    const arabicName  = cities[ci];
    const englishName = CITY_MAP[arabicName] || arabicName;
    let cityRows = 0;

    for (const month of MONTHS) {
      try {
        const doc    = await fetchPage(arabicName, month);
        const parsed = extractRows(doc, englishName);
        if (parsed.length === 0) {
          errors.push(`${englishName}/m${month}: no data`);
        } else {
          rows.push(...parsed);
          cityRows += parsed.length;
          total    += parsed.length;
        }
      } catch (e) {
        errors.push(`${englishName}/m${month}: ${e.message}`);
      }
    }

    console.log(`[esa_fetch] [${ci + 1}/${cities.length}] ${englishName}: ${cityRows} rows`);
  }

  if (errors.length) console.warn('[esa_fetch] Errors:', errors);

  // ── Download CSV ──────────────────────────────────────────────────────────
  const csv      = rows.join('\n') + '\n';
  const m0       = MONTHS[0];
  const mN       = MONTHS[MONTHS.length - 1];
  const filename = `egypt_esa_${YEAR}_m${m0}_m${mN}.csv`;

  const blob = new Blob([csv], { type: 'text/csv' });
  const blobUrl = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = blobUrl; a.download = filename;
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(blobUrl); a.remove(); }, 1000);

  console.log(`[esa_fetch] ✅ Done! ${total} rows → ${filename}`);
  console.log('[esa_fetch] Next: copy to assets/csv/ then run: dart run tool/csv_to_sqlite.dart');
})();
