/**
 * libya_fetch.js — Fetch Libya prayer times from salatcalendar.com
 *
 * Source: https://www.salatcalendar.com/index.php/countries/cities/121
 * (same site used to seed Saudi Arabia, Morocco, Tunisia data)
 *
 * USAGE:  node tool/libya_fetch.js
 *
 * OUTPUT:
 *   assets/csv/libya_prayer_times_2026.csv
 *   tool/libya_cities.json   (Arabic + English names — used to update
 *                             assets/db_countries.json + db_city_lists.json)
 *
 * Then run:  dart run tool/csv_to_json.dart
 */

'use strict';

const fs   = require('fs');
const path = require('path');

const BASE      = 'https://www.salatcalendar.com/index.php';
const COUNTRY   = 121; // Libya
const YEAR      = 2026;
const FROM_DATE = `1/1/${YEAR}`;

// ── HTTP helpers (cookie-aware, no external deps) ────────────────────────────

function makeJar() {
  const cookies = new Map();
  return {
    set(setCookieHeaders) {
      for (const raw of setCookieHeaders || []) {
        const kv = raw.split(';')[0].trim();
        const eq = kv.indexOf('=');
        if (eq > 0) cookies.set(kv.slice(0, eq), kv.slice(eq + 1));
      }
    },
    header() {
      return [...cookies.entries()].map(([k, v]) => `${k}=${v}`).join('; ');
    },
  };
}

async function httpGet(url, jar) {
  // Manual redirect handling — Node fetch with redirect:'follow' loses our
  // explicitly-set cookies (the server resets `lang` based on geolocation
  // during the redirect), so we follow each hop ourselves and re-send the jar.
  let current = url;
  for (let hop = 0; hop < 5; hop++) {
    const r = await fetch(current, {
      redirect: 'manual',
      headers: { 'Cookie': jar.header(), 'User-Agent': 'Mozilla/5.0' },
    });
    jar.set(r.headers.getSetCookie?.() ?? r.headers.raw?.()['set-cookie']);
    if (r.status >= 300 && r.status < 400 && r.headers.get('location')) {
      current = new URL(r.headers.get('location'), current).toString();
      continue;
    }
    return await r.text();
  }
  throw new Error(`Too many redirects from ${url}`);
}

async function httpPost(url, body, jar) {
  const r = await fetch(url, {
    method: 'POST',
    redirect: 'follow',
    headers: {
      'Cookie': jar.header(),
      'User-Agent': 'Mozilla/5.0',
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
    },
    body,
  });
  jar.set(r.headers.getSetCookie?.() ?? r.headers.raw?.()['set-cookie']);
  return await r.text();
}

// ── Parsers ──────────────────────────────────────────────────────────────────

function extractCityList(html) {
  const re = /select_city\/(\d+)"[^>]*class="card">[\s\S]*?<p class="card-text font-weight-semibold mb-0">\s*([^<]+?)\s*<\/p>/g;
  const out = [];
  let m;
  while ((m = re.exec(html)) !== null) {
    out.push({ id: m[1], name: m[2].trim() });
  }
  return out;
}

/// Year HTML contains rows of 8 <td>s:
///   date(dd/MM/yyyy), hijri, fajr, sunrise, dhuhr, asr, maghrib, isha
function parseYearHtml(html) {
  // Extract every <td class="no-wrap text-center">VALUE</td> in document order.
  const tdRe = /<td[^>]*class="no-wrap text-center"[^>]*>\s*([^<]+?)\s*<\/td>/g;
  const cells = [];
  let m;
  while ((m = tdRe.exec(html)) !== null) cells.push(m[1].trim());

  const rows = [];
  // Find first cell that looks like dd/MM/yyyy and read 8 cells per row from there.
  const dateRe = /^(\d{2})\/(\d{2})\/\d{4}$/;
  for (let i = 0; i + 7 < cells.length; ) {
    if (!dateRe.test(cells[i])) { i++; continue; }
    rows.push({
      date:    cells[i],
      fajr:    cells[i + 2],
      sunrise: cells[i + 3],
      dhuhr:   cells[i + 4],
      asr:     cells[i + 5],
      maghrib: cells[i + 6],
      isha:    cells[i + 7],
    });
    i += 8;
  }
  return rows;
}

const isHHMM = (s) => /^\d{2}:\d{2}$/.test(s);

// ── Main ─────────────────────────────────────────────────────────────────────

(async () => {
  // Step 1 — Arabic + English city lists.
  console.log('[libya_fetch] Loading city lists...');
  const arJar = makeJar();
  await httpGet(`${BASE}/app/lang/ar`, arJar);
  const arHtml = await httpGet(`${BASE}/countries/cities/${COUNTRY}`, arJar);
  const arCities = extractCityList(arHtml);

  const enJar = makeJar();
  await httpGet(`${BASE}/app/lang/en`, enJar);
  const enHtml = await httpGet(`${BASE}/countries/cities/${COUNTRY}`, enJar);
  const enCities = new Map(extractCityList(enHtml).map((c) => [c.id, c.name]));

  const cities = arCities.map((c) => ({
    id: c.id,
    ar: c.name,
    en: enCities.get(c.id) || c.name,
  }));
  console.log(`[libya_fetch] ${cities.length} cities found`);

  // Step 2 — Per-city year fetch in Arabic session (English city name used in CSV).
  const csvRows = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const errors = [];

  for (let i = 0; i < cities.length; i++) {
    const c = cities[i];
    try {
      // Re-using arJar; select_city sets the active city in the session.
      await httpGet(`${BASE}/countries/select_city/${c.id}`, arJar);

      const body  = `from=${encodeURIComponent(FROM_DATE)}&to=${encodeURIComponent(`31/12/${YEAR}`)}`;
      const json  = await httpPost(`${BASE}/app/get_period`, body, arJar);
      let html;
      try {
        html = JSON.parse(json).html;
      } catch {
        // Fallback to /app/get_year (single arg "day").
        const yJson = await httpPost(`${BASE}/app/get_year`, `day=${encodeURIComponent(FROM_DATE)}`, arJar);
        html = JSON.parse(yJson).html;
      }

      const rows = parseYearHtml(html).filter((r) =>
        isHHMM(r.fajr) && isHHMM(r.sunrise) && isHHMM(r.dhuhr) &&
        isHHMM(r.asr)  && isHHMM(r.maghrib) && isHHMM(r.isha)
      );

      if (rows.length < 350) {
        errors.push(`${c.en} (${c.id}): only ${rows.length} rows`);
      }
      for (const r of rows) {
        csvRows.push(`${c.en},${r.date},${r.fajr},${r.sunrise},${r.dhuhr},${r.asr},${r.maghrib},${r.isha}`);
      }
      console.log(`  [${i + 1}/${cities.length}] ${c.en.padEnd(28)} ${rows.length} days`);
    } catch (e) {
      errors.push(`${c.en} (${c.id}): ${e.message}`);
      console.warn(`  [${i + 1}/${cities.length}] ${c.en} FAILED: ${e.message}`);
    }
  }

  // Step 3 — Write outputs.
  const csvPath = path.join('assets', 'csv', `libya_prayer_times_${YEAR}.csv`);
  fs.writeFileSync(csvPath, csvRows.join('\n') + '\n', 'utf8');
  console.log(`\n[libya_fetch] CSV → ${csvPath}  (${csvRows.length - 1} rows)`);

  const cityJsonPath = path.join('tool', 'libya_cities.json');
  fs.writeFileSync(cityJsonPath, JSON.stringify(cities, null, 2), 'utf8');
  console.log(`[libya_fetch] City names → ${cityJsonPath}`);

  if (errors.length) {
    console.warn(`\n[libya_fetch] ${errors.length} warnings:`);
    for (const e of errors) console.warn('  ' + e);
  }
  console.log('\nNext: dart run tool/csv_to_json.dart');
})().catch((e) => { console.error(e); process.exit(1); });
