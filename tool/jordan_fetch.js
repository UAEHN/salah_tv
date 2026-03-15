/**
 * jordan_fetch.js — Fetch Jordan prayer times from awqaf.gov.jo
 *
 * HOW TO USE:
 *   1. Open https://www.awqaf.gov.jo/ar/Pages/PrayerTime in Chrome
 *   2. Open DevTools (F12) → Console tab
 *   3. Paste this entire script and press Enter
 *   4. Wait for it to finish (progress shown in console, ~45–90 min)
 *   5. A CSV file will download automatically
 *
 * OUTPUT FILE: jordan_awqaf_2026.csv
 * City names: Arabic, exactly as listed on the official website dropdown.
 *
 * NOTES:
 *   - The date-range search on this site crashes server-side (broken handler).
 *     Empty date fields are used instead; the script then navigates to
 *     Page$First to capture data from the earliest available date.
 *   - WAF blocks fetch()/XHR unless X-MicrosoftAjax: Delta=true is set.
 *   - Must POST to lowercase /ar/ URL (not /AR/).
 *   - Rate limit: ~5 burst requests; uses 1.5 s delay between pages,
 *     3 s between cities. On timeout/503, retries with 60/120/180 s waits.
 *
 * Then run:  dart run tool/csv_to_sqlite.dart
 */

(async () => {
  // ── Config ────────────────────────────────────────────────────────────────
  const PAGE     = 'https://www.awqaf.gov.jo/ar/Pages/PrayerTime';
  const END_DATE = '31/12/2026';
  const MAX_PAGES = 45;  // safety cap per city (~37 pages for a full year)

  // Arabic city names exactly as they appear in the website's dropdown
  const CITIES = [
    'عمان، البلقاء، الزرقاء، مادبا',
    'اربد',
    'الكرك',
    'الطفيلة',
    'معان',
    'العقبة',
    'الأغوار الشمالية',
    'جرش وعجلون',
    'المفرق',
    'أم القطين',
    'ذيبان',
    'الأزرق',
    'الأغوار الوسطى',
    'الشوبك والبتراء',
    'الظليل والهاشمية',
    'ارحاب',
    'العمري',
    'الصفاوي',
    'الرويشد',
    'حدود الكرامة',
    'القطرانة',
    'الحسا',
    'الحسينية الجنوبية',
    'غور الصافي',
    'قريقرة',
    'غرندل',
    'رحمة',
    'القويرة',
    'رم',
    'المدورة',
    'الجفر',
    'باير',
    'القدس',
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  // Parse ASP.NET UpdatePanel delta: length|type|id|value|…
  function parseDeltas(text) {
    const result = {};
    let pos = 0;
    while (pos < text.length) {
      const pi = text.indexOf('|', pos);
      if (pi < 0) break;
      const len = parseInt(text.substring(pos, pi));
      if (isNaN(len)) { pos = pi + 1; continue; }
      const typeEnd = text.indexOf('|', pi + 1);
      const idEnd   = text.indexOf('|', typeEnd + 1);
      const id      = text.substring(typeEnd + 1, idEnd);
      const value   = text.substring(idEnd + 1, idEnd + 1 + len);
      pos = idEnd + 1 + len + 1;
      result[id] = value;
    }
    return result;
  }

  // Extract prayer-time data rows from the UpdatePanel HTML fragment.
  // Returns arrays: [date, fajr, sunrise, dhuhr, asr, maghrib, isha]
  function extractRows(html) {
    const doc   = new DOMParser().parseFromString(html, 'text/html');
    const table = Array.from(doc.querySelectorAll('table')).find(t => t.rows.length > 3);
    if (!table) return [];
    return Array.from(table.rows).slice(1)
      .map(r => Array.from(r.cells).map(c => c.textContent.trim()))
      .filter(cells => cells.length >= 7 && /^\d{2}\/\d{2}\/\d{4}$/.test(cells[0]));
  }

  // XHR POST with ASP.NET AJAX headers — bypasses WAF that blocks plain fetch/XHR.
  // Retries on 503 / timeout with escalating back-off.
  async function xhrPost(vs, ev, vsg, eventTarget, eventArg, city) {
    for (let attempt = 1; attempt <= 3; attempt++) {
      const result = await new Promise((resolve) => {
        const xhr = new XMLHttpRequest();
        xhr.open('POST', PAGE, true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        xhr.setRequestHeader('X-MicrosoftAjax', 'Delta=true');
        xhr.setRequestHeader('Cache-Control', 'no-cache');
        const body = new URLSearchParams({
          'ScriptManager':        `ctl00$ScriptManager1|${eventTarget}`,
          '__EVENTTARGET':        eventTarget,
          '__EVENTARGUMENT':      eventArg,
          '__ASYNCPOST':          'true',
          '__VIEWSTATE':          vs,
          '__VIEWSTATEGENERATOR': vsg,
          '__EVENTVALIDATION':    ev,
          'ctl00$MainContent$DropCompany':  city,
          'ctl00$MainContent$txtFromDate':  '',
          'ctl00$MainContent$txtToDate':    '',
        });
        xhr.timeout   = 20000;
        xhr.onload    = () => resolve({ status: xhr.status, text: xhr.responseText });
        xhr.onerror   = () => resolve({ status: 0, text: '' });
        xhr.ontimeout = () => resolve({ status: 0, text: '' });
        xhr.send(body.toString());
      });

      if (result.status === 200) return result.text;

      const wait = attempt * 60000; // 60 s → 120 s → 180 s
      console.warn(`[jordan_fetch] HTTP ${result.status} (attempt ${attempt}) — waiting ${wait / 1000}s...`);
      await sleep(wait);
    }
    return '';
  }

  // ── Main ──────────────────────────────────────────────────────────────────

  const vsg = document.querySelector('input[name="__VIEWSTATEGENERATOR"]').value;
  let vs    = document.querySelector('input[name="__VIEWSTATE"]').value;
  let ev    = document.querySelector('input[name="__EVENTVALIDATION"]').value;

  const allRows = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const errors  = [];

  console.log(`[jordan_fetch] Starting: ${CITIES.length} cities`);

  for (let ci = 0; ci < CITIES.length; ci++) {
    const city = CITIES[ci];
    let cityRowCount = 0;

    // ── Step 1: Trigger city search (empty dates) ──────────────────────────
    let resp = await xhrPost(vs, ev, vsg,
      'ctl00$MainContent$btn_search', '', city);

    if (!resp || resp.includes('pageRedirect')) {
      errors.push(`${city}: search failed`);
      console.warn(`[jordan_fetch] [${ci + 1}/${CITIES.length}] ${city}: search failed — skipping`);
      continue;
    }

    let deltas = parseDeltas(resp);
    if (deltas['__VIEWSTATE'])       vs = deltas['__VIEWSTATE'];
    if (deltas['__EVENTVALIDATION']) ev = deltas['__EVENTVALIDATION'];

    // ── Step 2: Jump to Page$First to capture earliest available data ──────
    // The GridView may hold the full year but open at today's page by default.
    await sleep(1500);
    const respFirst = await xhrPost(vs, ev, vsg,
      'ctl00$MainContent$gvWebparts', 'Page$First', city);

    let startingHtml = '';
    if (respFirst && !respFirst.includes('pageRedirect')) {
      const d = parseDeltas(respFirst);
      if (d['__VIEWSTATE'])       vs = d['__VIEWSTATE'];
      if (d['__EVENTVALIDATION']) ev = d['__EVENTVALIDATION'];
      startingHtml = d['MainContent_UpdatePanel1'] || '';
    } else {
      // Page$First failed — fall back to the search result (page 1)
      startingHtml = deltas['MainContent_UpdatePanel1'] || '';
    }

    // Collect rows from first/current page
    let firstPageRows = extractRows(startingHtml);
    const firstDate   = firstPageRows[0]?.[0] ?? '?';
    firstPageRows.forEach(r => {
      allRows.push(`${city},${r[0]},${r[1]},${r[2]},${r[3]},${r[4]},${r[5]},${r[6]}`);
      cityRowCount++;
    });

    let reachedEnd = firstPageRows.some(r => r[0] === END_DATE);

    // ── Step 3: Paginate forward until December 31 ────────────────────────
    for (let page = 2; page <= MAX_PAGES && !reachedEnd; page++) {
      await sleep(1500);

      resp = await xhrPost(vs, ev, vsg,
        'ctl00$MainContent$gvWebparts', `Page$${page}`, city);

      if (!resp || resp.includes('pageRedirect')) {
        errors.push(`${city}/p${page}: pagination error`);
        break;
      }

      deltas = parseDeltas(resp);
      if (deltas['__VIEWSTATE'])       vs = deltas['__VIEWSTATE'];
      if (deltas['__EVENTVALIDATION']) ev = deltas['__EVENTVALIDATION'];

      const pageRows = extractRows(deltas['MainContent_UpdatePanel1'] || '');
      if (pageRows.length === 0) break;

      pageRows.forEach(r => {
        allRows.push(`${city},${r[0]},${r[1]},${r[2]},${r[3]},${r[4]},${r[5]},${r[6]}`);
        cityRowCount++;
      });

      if (pageRows.some(r => r[0] === END_DATE)) reachedEnd = true;
    }

    console.log(`[jordan_fetch] [${ci + 1}/${CITIES.length}] ${city}: ${cityRowCount} rows (from ${firstDate})`);
    await sleep(3000);
  }

  if (errors.length) console.warn('[jordan_fetch] Errors:', errors);

  // ── Download CSV ──────────────────────────────────────────────────────────
  const csv      = allRows.join('\n') + '\n';
  const filename = 'jordan_awqaf_2026.csv';

  const blob = new Blob([csv], { type: 'text/csv' });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement('a');
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 1000);

  console.log(`[jordan_fetch] ✅ Done! ${allRows.length - 1} rows → ${filename}`);
  console.log('[jordan_fetch] Earliest data found logged above per city (from DD/MM/YYYY).');
  console.log('[jordan_fetch] Next: copy to assets/csv/ then run: dart run tool/csv_to_sqlite.dart');
})();
