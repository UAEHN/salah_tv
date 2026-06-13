/**
 * oman_fetch.js — Fetch official Oman prayer times from وزارة الأوقاف والشؤون الدينية
 * (Ministry of Endowments & Religious Affairs) — https://www.mara.gov.om/arabic/calendar_page2.asp
 *
 * HOW TO USE:
 *   1. Open https://www.mara.gov.om/arabic/calendar_page2.asp in Chrome
 *   2. Open DevTools (F12) → Console tab
 *   3. Paste this entire script and press Enter
 *   4. Wait for it to finish (progress shown in console, ~30 min)
 *   5. A CSV file downloads automatically
 *
 * OUTPUT FILE: oman_prayer_times_2026.csv
 *   Header: City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha
 *   Cities: English transliterations (slug source) — see CITY_MAP.
 *   Contains BOTH 2026 and 2027 rows per city (the cache DB matches the exact
 *   year first, so storing both years gives each its official data; the
 *   year-agnostic fallback in sqlite_prayer_queries.dart covers 2028+).
 *
 * SITE NOTES:
 *   - Plain ASP form POST: fields year, month (1-12), CityID (0-85), B1.
 *   - Response is windows-1256 encoded HTML; the prayer table is the first
 *     <table> with >5 rows. Columns: تاريخ, الفجر, الشروق, الظهر, العصر, المغرب, العشاء.
 *   - Times are 12-hour WITHOUT am/pm. Fajr/Sunrise/Dhuhr are correct as-is;
 *     Asr/Maghrib/Isha are PM → add 12h. (Verified against the prior calculated
 *     CSV: Muscat 01/01 asr 03:16→15:16, maghrib 05:36→17:36, isha 06:52→18:52.)
 *
 * Then: copy to assets/csv/ and run  dart run tool/csv_to_json.dart
 */

(async () => {
  const PAGE  = 'https://www.mara.gov.om/arabic/calendar_page2.asp';
  const YEARS = [2026, 2027];

  // CityID (0-85) → English name. Official MARA wilayat/locality dropdown order.
  const CITY_MAP = {
    0:'Muscat',1:'Ibra',2:'Adam',3:'Izki',4:'Al Ashkharah',5:'Al Buraimi',
    6:'Al Jazer',7:'Al Jammah',8:'Al Hashman',9:'Al Hallaniyat',10:'Al Hamra',
    11:'Al Khabourah',12:'Al Khadrafi',13:'Al Khuwair',14:'Al Duqm',15:'Al Rustaq',
    16:'Al Awabi',17:'Al Qabil',18:'Al Qabil Al Dhahirah',19:'Al Kamil Wal Wafi',
    20:'Al Mudhaibi',21:'Al Mamoura',22:'Al Huwaisah',23:'Al Wasit',24:'Al Wasil',
    25:'Bukha',26:'Bidbid',27:'Badiyah',28:'Barka',29:'Bahla',30:'Thumrait',
    31:'Jiddat Al Harasis',32:'Jalan Bani Bu Hassan',33:'Jalan Bani Bu Ali',
    34:'Habroot',35:'Hij',36:'Khazan',37:'Dibba Al Bayah',38:'Ras Al Hadd',
    39:'Ras Madrakah',40:'Rakhyut',41:'Ramal Al Wahiba',42:'Raysut',43:'Sadah',
    44:'Samail',45:'Samad Al Shan',46:'Sinaw',47:'Suwaiq',48:'Sih Al Rawl',
    49:'Saiq',50:'Shalim',51:'Shinas',52:'Sohar',53:'Saham',54:'Sarab',
    55:'Sarfait',56:'Salalah',57:'Sur',58:'Dank',59:'Taqah',60:'Dhalkut',
    61:'Ibri',62:'Fahud',63:'Qarn Al Alam',64:'Quriyat',65:'Kanhat',66:'Liwa',
    67:'Mahdah',68:'Mahout',69:'Madha',70:'Mirbat',71:'Marmar',72:'Marmoul',
    73:'Musandam',74:'Al Masnaah',75:'Masirah',76:'Muqshin',77:'Manah',
    78:'Nakhal',79:'Nizwa',80:'Nimr',81:'Harweel',82:'Haima',
    83:'Wadi Bani Khalid',84:'Wadi Hibi',85:'Yanqul',
  };

  // ── Helpers ──────────────────────────────────────────────────────────────
  const pad   = n => String(n).padStart(2, '0');
  const sleep = ms => new Promise(r => setTimeout(r, ms));

  // 12h → 24h. pm=true for Asr/Maghrib/Isha (hour 1-11 means PM here).
  const to24 = (s, pm) => {
    let [h, m] = s.split(':').map(x => parseInt(x, 10));
    if (pm && h < 12) h += 12;
    return pad(h) + ':' + pad(m);
  };

  const errors = [];

  // Fetch one (city, year, month). Returns ["dd/MM/yyyy,fajr,...,isha", ...].
  async function fetchMonth(cityIdx, year, month) {
    const body = new URLSearchParams({
      year: String(year), month: String(month), CityID: String(cityIdx), B1: 'عرض',
    });
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const resp = await fetch(PAGE, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: body.toString(),
        });
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        const html = new TextDecoder('windows-1256').decode(await resp.arrayBuffer());
        const doc  = new DOMParser().parseFromString(html, 'text/html');
        const table = Array.from(doc.querySelectorAll('table')).find(t => t.rows.length > 5);
        if (!table) throw new Error('no table');
        const cells = Array.from(table.rows).slice(1)
          .map(r => Array.from(r.cells).map(c => c.textContent.trim()))
          .filter(c => /^\d{1,2}\/\d{1,2}\/\d{4}$/.test(c[0]));
        return cells.map(c => {
          const [d, mo, y] = c[0].split('/');
          return `${pad(d)}/${pad(mo)}/${y},${c[1]},${c[2]},${c[3]},`
               + `${to24(c[4], true)},${to24(c[5], true)},${to24(c[6], true)}`;
        });
      } catch (e) {
        if (attempt === 3) { errors.push(`city${cityIdx} ${year}/${month}: ${e.message}`); return []; }
        await sleep(2000 * attempt);
      }
    }
    return [];
  }

  // ── Main ─────────────────────────────────────────────────────────────────
  const rows = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const ids  = Object.keys(CITY_MAP).map(Number);
  console.log(`[oman_fetch] Starting: ${ids.length} cities × ${YEARS.length} years`);

  for (const ci of ids) {
    const name = CITY_MAP[ci];
    let n = 0;
    for (const y of YEARS) {
      for (let m = 1; m <= 12; m++) {
        const recs = await fetchMonth(ci, y, m);
        recs.forEach(r => { rows.push(`${name},${r}`); n++; });
        await sleep(100);
      }
    }
    console.log(`[oman_fetch] [${ci + 1}/${ids.length}] ${name}: ${n} rows`);
  }

  if (errors.length) console.warn('[oman_fetch] Errors:', errors);

  // ── Download CSV ───────────────────────────────────────────────────────────
  const csv  = rows.join('\n') + '\n';
  const blob = new Blob([csv], { type: 'text/csv' });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement('a');
  a.href = url; a.download = 'oman_prayer_times_2026.csv';
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 1000);

  console.log(`[oman_fetch] ✅ Done! ${rows.length - 1} rows → oman_prayer_times_2026.csv`);
})();
