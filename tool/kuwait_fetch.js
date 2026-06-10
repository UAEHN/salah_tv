/**
 * kuwait_fetch.js — Fetch Kuwait prayer times from تقويم العجيري (Al-Ojeiri)
 *
 * HOW TO USE:
 *   1. Open https://alojeiri.com/ar/ojeiri-calendar in Chrome
 *   2. Open DevTools (F12) → Console tab
 *   3. Paste this entire script and press Enter
 *   4. Wait for it to finish (~10-20 s for all 9 regions)
 *   5. A CSV file will download automatically
 *
 * OUTPUT FILE: kuwait_prayer_times_2026.csv
 * City names: Arabic, exactly as listed in the official Al-Ojeiri city list.
 *
 * NOTES:
 *   - Official source: Kuwait Ministry of Awqaf schedule per the astronomical
 *     calendar of Dr. Saleh Al-Ojeiri (alojeiri.com).
 *   - Data comes from the site's own JSON API: /api/prayer-times/range
 *     (?from=YYYY-MM-DD&to=YYYY-MM-DD&city=<slug>). The whole year returns in
 *     one request per city ({ days: [{date,fajr,sunrise,dhuhr,asr,maghrib,isha}] }).
 *   - Must run from the alojeiri.com origin: Cloudflare blocks off-site/curl
 *     requests, and same-origin avoids CORS.
 *   - Kuwait publishes ONE base schedule (مدينة الكويت) plus per-region minute
 *     offsets. The API already applies each region's offset, so we just fetch
 *     every region directly — no client-side offset math.
 *
 * Then run:  dart run tool/csv_to_json.dart
 */

(async () => {
  // ── Config ────────────────────────────────────────────────────────────────
  const YEAR = 2026;
  const API  = '/api/prayer-times/range';

  // Region slug → Arabic display name (from the official Al-Ojeiri city list).
  // offset shown for reference only; the API already bakes it into the times.
  const CITIES = [
    { slug: 'kuwait-city', name: 'مدينة الكويت' }, // offset  0 (base)
    { slug: 'jahra',       name: 'الجهراء'      }, // offset +2
    { slug: 'subiya',      name: 'الصبية'       }, // offset +3
    { slug: 'abdali',      name: 'العبدلي'      }, // offset +2
    { slug: 'salmi',       name: 'السالمي'      }, // offset +6
    { slug: 'nuwaiseeb',   name: 'النويصيب'     }, // offset -2
    { slug: 'wafra',       name: 'الوفرة'       }, // offset -1
    { slug: 'failaka',     name: 'فيلكا'        }, // offset -2
    { slug: 'khairan',     name: 'الخيران'      }, // offset -3
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────
  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  // Fetch one region's full year with retry.
  async function fetchCity(slug) {
    const url = `${API}?from=${YEAR}-01-01&to=${YEAR}-12-31&city=${slug}`;
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const json = await res.json();
        const days = json.days || json;
        if (!Array.isArray(days) || days.length === 0) throw new Error('empty days');
        return days;
      } catch (err) {
        const wait = attempt * 3000;
        console.warn(`[kuwait_fetch] ${slug} attempt ${attempt} failed: ${err.message} — retrying in ${wait / 1000}s`);
        if (attempt < 3) await sleep(wait);
      }
    }
    return null;
  }

  // ── Main ──────────────────────────────────────────────────────────────────
  const rows   = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const errors = [];

  console.log(`[kuwait_fetch] Starting: ${CITIES.length} regions for ${YEAR}`);

  for (let i = 0; i < CITIES.length; i++) {
    const city = CITIES[i];
    const days = await fetchCity(city.slug);

    if (!days) {
      errors.push(city.slug);
      console.warn(`[kuwait_fetch] [${i + 1}/${CITIES.length}] ${city.name}: FAILED — skipping`);
      continue;
    }

    for (const d of days) {
      rows.push([
        city.name, d.date, d.fajr, d.sunrise, d.dhuhr, d.asr, d.maghrib, d.isha,
      ].join(','));
    }
    console.log(`[kuwait_fetch] [${i + 1}/${CITIES.length}] ${city.name}: ${days.length} days`);
    await sleep(500);
  }

  if (errors.length) console.warn('[kuwait_fetch] Failed regions:', errors);

  // ── Download CSV ──────────────────────────────────────────────────────────
  const csv      = rows.join('\n') + '\n';
  const filename = `kuwait_prayer_times_${YEAR}.csv`;

  const blob = new Blob([csv], { type: 'text/csv' });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement('a');
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 1000);

  console.log(`[kuwait_fetch] ✅ Done! ${rows.length - 1} rows → ${filename}`);
  console.log('[kuwait_fetch] Next: copy to assets/csv/ then run: dart run tool/csv_to_json.dart');
})();
