/**
 * singapore_fetch.js — Fetch Singapore prayer times from data.gov.sg (MUIS)
 *
 * HOW TO USE:
 *   1. Open any webpage in Chrome (e.g. https://data.gov.sg)
 *   2. Open DevTools (F12) → Console tab
 *   3. Paste this entire script and press Enter
 *   4. A CSV file will download automatically (~5-15 seconds)
 *
 * OUTPUT FILE: singapore_prayer_times_2026.csv
 *
 * NOTES:
 *   - Uses the Download API (not datastore_search) to avoid 429 rate limits.
 *   - Flow: initiate-download → poll until URL ready → fetch CSV → convert.
 *   - No authentication required (public dataset).
 *   - Singapore has one unified timezone — single city "Singapore".
 *   - Dataset ID may change each year. Find new ones at:
 *     https://data.gov.sg/datasets?query=muis+prayer
 *
 * Then run:  dart run tool/csv_to_sqlite.dart
 */

(async () => {
  // ── Config ────────────────────────────────────────────────────────────────
  const YEAR      = 2026;
  const CITY_NAME = 'Singapore';

  // 2026 MUIS Prayer Timetable dataset
  // Page: https://data.gov.sg/datasets/d_d441e7242e78efc566024dd5b0d9829c/view
  const DATASET_ID = 'd_d441e7242e78efc566024dd5b0d9829c';
  const BASE       = 'https://api-open.data.gov.sg/v1/public/api/datasets';

  // ── Helpers ───────────────────────────────────────────────────────────────

  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  // "HH:MM:SS" or "HH:MM" → "HH:MM"
  function normalizeTime(t) {
    if (!t) return '';
    const parts = t.trim().split(':');
    return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
  }

  // Parse CSV text → array of objects keyed by header row
  function parseCsv(text) {
    const lines = text.trim().split('\n');
    const headers = lines[0].split(',').map(h => h.trim().replace(/^"|"$/g, ''));
    return lines.slice(1).map(line => {
      const vals = line.split(',').map(v => v.trim().replace(/^"|"$/g, ''));
      return Object.fromEntries(headers.map((h, i) => [h, vals[i] ?? '']));
    });
  }

  // ── Step 1: Initiate download ─────────────────────────────────────────────

  console.log('[singapore_fetch] Initiating download...');

  let initiateRes;
  try {
    initiateRes = await fetch(`${BASE}/${DATASET_ID}/initiate-download`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!initiateRes.ok) throw new Error(`HTTP ${initiateRes.status}`);
  } catch (err) {
    console.error(`[singapore_fetch] ❌ Initiate failed: ${err.message}`);
    return;
  }

  const initiateJson = await initiateRes.json();
  console.log('[singapore_fetch] Initiate response:', initiateJson?.data?.message ?? 'OK');

  // ── Step 2: Poll until download URL is ready ──────────────────────────────

  console.log('[singapore_fetch] Polling for download URL...');

  let downloadUrl = null;
  for (let attempt = 1; attempt <= 20; attempt++) {
    await sleep(2000);

    try {
      const pollRes  = await fetch(`${BASE}/${DATASET_ID}/poll-download`);
      if (!pollRes.ok) throw new Error(`HTTP ${pollRes.status}`);
      const pollJson = await pollRes.json();

      // URL is ready when the response contains a download link
      const url = pollJson?.data?.url;
      if (url) {
        downloadUrl = url;
        console.log(`[singapore_fetch] Download URL ready (attempt ${attempt})`);
        break;
      }

      console.log(`[singapore_fetch] Poll ${attempt}: not ready yet — ${pollJson?.data?.message ?? 'waiting...'}`);
    } catch (err) {
      console.warn(`[singapore_fetch] Poll ${attempt} error: ${err.message}`);
    }
  }

  if (!downloadUrl) {
    console.error('[singapore_fetch] ❌ Timed out waiting for download URL.');
    return;
  }

  // ── Step 3: Download the CSV file ─────────────────────────────────────────

  console.log('[singapore_fetch] Downloading CSV...');

  let csvText;
  try {
    const dlRes = await fetch(downloadUrl);
    if (!dlRes.ok) throw new Error(`HTTP ${dlRes.status}`);
    csvText = await dlRes.text();
  } catch (err) {
    console.error(`[singapore_fetch] ❌ Download failed: ${err.message}`);
    return;
  }

  // ── Step 4: Parse and convert to app CSV format ───────────────────────────

  const records = parseCsv(csvText);
  if (!records.length) {
    console.error('[singapore_fetch] ❌ No records parsed from CSV.');
    return;
  }

  const outputRows = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];

  for (const d of records) {
    // Filter to requested year only (consolidated dataset spans multiple years)
    if (d.Date && !d.Date.startsWith(String(YEAR))) continue;

    // Column names (Malay): Subuh=Fajr, Syuruk=Sunrise, Zohor=Dhuhr,
    //                        Asar=Asr, Maghrib=Maghrib, Isyak=Isha
    outputRows.push([
      CITY_NAME,
      d.Date,                   // already YYYY-MM-DD
      normalizeTime(d.Subuh),
      normalizeTime(d.Syuruk),
      normalizeTime(d.Zohor),
      normalizeTime(d.Asar),
      normalizeTime(d.Maghrib),
      normalizeTime(d.Isyak),
    ].join(','));
  }

  console.log(`[singapore_fetch] ${outputRows.length - 1} days parsed.`);

  // ── Step 5: Download output CSV ───────────────────────────────────────────

  const filename = `singapore_prayer_times_${YEAR}.csv`;
  const blob     = new Blob([outputRows.join('\n') + '\n'], { type: 'text/csv' });
  const url      = URL.createObjectURL(blob);
  const a        = document.createElement('a');
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 1000);

  console.log(`[singapore_fetch] ✅ Done! → ${filename}`);
  console.log('[singapore_fetch] Next: copy to assets/csv/ then run: dart run tool/csv_to_sqlite.dart');
})();
