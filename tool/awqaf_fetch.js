/**
 * awqaf_fetch.js — Fetch UAE prayer times from awqaf.gov.ae
 *
 * HOW TO USE:
 *   1. Open https://www.awqaf.gov.ae/prayer-times in Chrome
 *   2. Scroll down and click "المزيد" (More) to open the monthly list
 *   3. Open DevTools (F12) → Console tab
 *   4. Paste this entire script and press Enter
 *   5. A CSV file will download automatically
 *
 * OUTPUT FILE: uae_awqaf_2026_2027.csv  (full 2026 + Jan–Jun 2027; see JOBS below)
 * Then: send the downloaded CSV back here to merge + run dart run tool/csv_to_json.dart
 */

(async () => {
  // ── Config ────────────────────────────────────────────────────────────────
  // Each job is [year, [months...]]: full 2026 refresh + Jan–Jun 2027
  // (Jun 2027 is the last month the source publishes).
  const JOBS = [
    [2026, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]],
    [2027, [1, 2, 3, 4, 5, 6]],
  ];
  const BASE = 'https://mobileappapi.awqaf.gov.ae/APIS/v3/prayer-time';

  // City definitions: [DB name, emirateId, cityId]
  const CITIES = [
    ['Dubai',             2, 32],
    ['Abu Dhabi',         1,  1],
    ['Sharjah',           3, 33],
    ['Ajman',             4, 41],
    ['Umm Al Quwain',     5, 44],
    ['Ras Al Khaimah',    6, 45],
    ['Fujairah',          7, 52],
    ['Al Ain',            1,  2],
    ['Dibba Al-Fujairah', 7, 53],
    ['Khor Fakkan',       3, 36],  // Sharjah Eastern Coast
    ['Kalba',             3, 36],  // Sharjah Eastern Coast
    ['Hatta',             2, 60],
    ['Al Dhaid',          3, 34],
    ['Ruwais',            1, 27],
    ['Madinat Zayed',     1, 25],
  ];

  // ── Step 1: Get Bearer token by triggering the Download button ────────────
  console.log('[awqaf_fetch] Capturing token...');

  const token = await new Promise((resolve, reject) => {
    let resolved = false;

    // Intercept XHR to grab the Authorization header
    const origOpen = XMLHttpRequest.prototype.open;
    const origSetHeader = XMLHttpRequest.prototype.setRequestHeader;
    XMLHttpRequest.prototype.setRequestHeader = function(name, value) {
      if (!resolved && name.toLowerCase() === 'authorization' && value.startsWith('Bearer')) {
        resolved = true;
        XMLHttpRequest.prototype.setRequestHeader = origSetHeader;
        XMLHttpRequest.prototype.open = origOpen;
        resolve(value);
      }
      return origSetHeader.apply(this, arguments);
    };

    // Click the "تحميل" (Download) button in the monthly list
    const btn = Array.from(document.querySelectorAll('button'))
      .find(b => b.innerText.trim() === 'تحميل');
    if (!btn) {
      reject(new Error('Download button not found. Click "المزيد" first to open the monthly list.'));
      return;
    }
    btn.click();

    setTimeout(() => {
      if (!resolved) reject(new Error('Token not captured — try clicking the button manually.'));
    }, 5000);
  });

  console.log('[awqaf_fetch] Token captured ✓');

  // ── Step 2: Fetch all cities × months ────────────────────────────────────
  const headers = { 'Authorization': token, 'Accept': 'application/json' };

  function parseTime(iso) {
    const m = (iso || '').match(/T(\d{2}):(\d{2})/);
    return m ? `${m[1]}:${m[2]}` : null;
  }
  function parseDate(iso) {
    // ISO yyyy-MM-dd to match the existing assets/csv/uae_prayer_times_2026.csv format.
    const m = (iso || '').match(/^(\d{4})-(\d{2})-(\d{2})/);
    return m ? `${m[1]}-${m[2]}-${m[3]}` : null;
  }

  const rows = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const errors = [];

  for (const [name, emirId, cityId] of CITIES) {
    for (const [year, months] of JOBS) {
      for (const month of months) {
        const url = `${BASE}/prayertimes/${year}/${month}/${emirId}/${cityId}`;
        try {
          const r = await fetch(url, { headers });
          if (!r.ok) { errors.push(`${name}/${year}-m${month}: ${r.status}`); continue; }
          const data = await r.json();
          let count = 0;
          for (const d of (data.prayerData || [])) {
            const date    = parseDate(d.gDate);
            const fajr    = parseTime(d.fajr);
            const sunrise = parseTime(d.shurooq);
            const dhuhr   = parseTime(d.zuhr);
            const asr     = parseTime(d.asr);
            const maghrib = parseTime(d.maghrib);
            const isha    = parseTime(d.isha);
            if (date && fajr && sunrise && dhuhr && asr && maghrib && isha) {
              rows.push(`${name},${date},${fajr},${sunrise},${dhuhr},${asr},${maghrib},${isha}`);
              count++;
            }
          }
          console.log(`[awqaf_fetch] ${name} ${year}-${String(month).padStart(2, '0')}: ${count} days`);
        } catch (e) {
          errors.push(`${name}/${year}-m${month}: ${e.message}`);
        }
      }
    }
  }

  if (errors.length) console.warn('[awqaf_fetch] Errors:', errors);

  // ── Step 3: Download CSV ──────────────────────────────────────────────────
  const csv = rows.join('\n') + '\n';
  const first = JOBS[0], last = JOBS[JOBS.length - 1];
  const filename = `uae_awqaf_${first[0]}_${last[0]}.csv`;

  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 1000);

  console.log(`[awqaf_fetch] ✅ Done! ${rows.length - 1} rows → ${filename}`);
  console.log('[awqaf_fetch] Next: send this CSV to Claude to merge into assets/csv/uae_prayer_times_2026.csv, then it runs: dart run tool/csv_to_json.dart');
})();
