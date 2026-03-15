/**
 * malaysia_fetch.js — Fetch Malaysia prayer times from e-solat.gov.my (JAKIM)
 *
 * HOW TO USE:
 *   1. Open https://www.e-solat.gov.my in Chrome
 *   2. Open DevTools (F12) → Console tab
 *   3. Paste this entire script and press Enter
 *   4. Wait for it to finish (~3-5 min for all 58 zones)
 *   5. A CSV file will download automatically
 *
 * OUTPUT FILE: malaysia_prayer_times_2026.csv
 *
 * NOTES:
 *   - Must run from e-solat.gov.my domain to avoid CORS errors.
 *   - API is public, no authentication required.
 *   - Uses POST with period=duration for explicit year range.
 *   - Zones cover all 14 states + 3 Federal Territories.
 *   - On error, retries up to 3 times with 5s back-off.
 *
 * Then run:  dart run tool/csv_to_sqlite.dart
 */

(async () => {
  // ── Config ────────────────────────────────────────────────────────────────
  const YEAR     = 2026;
  const API      = 'https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat';
  const DELAY_MS = 1500;  // between zones

  // Zone code → display name (city/area names shown in the app)
  // Sources: JAKIM official zone list
  const ZONES = [
    // Johor
    { code: 'JHR01', name: 'Johor - Pulau Aur & Pemanggil' },
    { code: 'JHR02', name: 'Johor - Johor Bahru' },
    { code: 'JHR03', name: 'Johor - Kluang & Pontian' },
    { code: 'JHR04', name: 'Johor - Batu Pahat & Muar' },
    // Kedah
    { code: 'KDH01', name: 'Kedah - Kota Setar & Kubang Pasu' },
    { code: 'KDH02', name: 'Kedah - Kuala Muda & Yan' },
    { code: 'KDH03', name: 'Kedah - Padang Terap & Sik' },
    { code: 'KDH04', name: 'Kedah - Baling' },
    { code: 'KDH05', name: 'Kedah - Kulim & Bandar Baharu' },
    { code: 'KDH06', name: 'Kedah - Langkawi' },
    { code: 'KDH07', name: 'Kedah - Gunung Jerai' },
    // Kelantan
    { code: 'KTN01', name: 'Kelantan - Kota Bharu' },
    { code: 'KTN03', name: 'Kelantan - Gua Musang' },
    // Melaka
    { code: 'MLK01', name: 'Melaka' },
    // Negeri Sembilan
    { code: 'NGS01', name: 'N. Sembilan - Jempol & Tampin' },
    { code: 'NGS02', name: 'N. Sembilan - Seremban & Port Dickson' },
    // Pahang
    { code: 'PHG01', name: 'Pahang - Pulau Tioman' },
    { code: 'PHG02', name: 'Pahang - Rompin' },
    { code: 'PHG03', name: 'Pahang - Kuantan & Temerloh' },
    { code: 'PHG04', name: 'Pahang - Raub' },
    { code: 'PHG05', name: 'Pahang - Cameron Highland & Bentong' },
    { code: 'PHG06', name: 'Pahang - Maran & Chenor' },
    // Perlis
    { code: 'PLS01', name: 'Perlis - Kangar & Arau' },
    // Pulau Pinang
    { code: 'PNG01', name: 'Pulau Pinang' },
    // Perak
    { code: 'PRK01', name: 'Perak - Tapah & Tanjung Malim' },
    { code: 'PRK02', name: 'Perak - Ipoh & Kuala Kangsar' },
    { code: 'PRK03', name: 'Perak - Lenggong & Pengkalan Hulu' },
    { code: 'PRK04', name: 'Perak - Temengor & Belum' },
    { code: 'PRK05', name: 'Perak - Teluk Intan & Manjung' },
    { code: 'PRK06', name: 'Perak - Taiping & Bagan Serai' },
    { code: 'PRK07', name: 'Perak - Bukit Larut' },
    // Sabah
    { code: 'SBH01', name: 'Sabah - Sandakan' },
    { code: 'SBH02', name: 'Sabah - Tawau' },
    { code: 'SBH03', name: 'Sabah - Lahad Datu' },
    { code: 'SBH04', name: 'Sabah - Kudat' },
    { code: 'SBH05', name: 'Sabah - Kota Belud' },
    { code: 'SBH06', name: 'Sabah - Kota Kinabalu' },
    { code: 'SBH07', name: 'Sabah - Penampang & Papar' },
    { code: 'SBH08', name: 'Sabah - Ranau & Kota Marudu' },
    { code: 'SBH09', name: 'Sabah - Keningau & Tenom' },
    // Selangor
    { code: 'SGR01', name: 'Selangor - Shah Alam & Petaling' },
    { code: 'SGR02', name: 'Selangor - Kuala Selangor' },
    { code: 'SGR03', name: 'Selangor - Klang & Kuala Langat' },
    // Sarawak
    { code: 'SWK01', name: 'Sarawak - Limbang & Lawas' },
    { code: 'SWK02', name: 'Sarawak - Miri & Bintulu' },
    { code: 'SWK03', name: 'Sarawak - Sibu & Mukah' },
    { code: 'SWK04', name: 'Sarawak - Sri Aman & Serian' },
    { code: 'SWK05', name: 'Sarawak - Kuching & Bau' },
    { code: 'SWK06', name: 'Sarawak - Sarikei' },
    { code: 'SWK07', name: 'Sarawak - Matu & Daro' },
    { code: 'SWK08', name: 'Sarawak - Betong & Saratok' },
    { code: 'SWK09', name: 'Sarawak - Kapit & Belaga' },
    // Terengganu
    { code: 'TRG01', name: 'Terengganu - Kuala Terengganu' },
    { code: 'TRG02', name: 'Terengganu - Besut & Setiu' },
    { code: 'TRG03', name: 'Terengganu - Hulu Terengganu' },
    { code: 'TRG04', name: 'Terengganu - Kemaman & Dungun' },
    // Federal Territories
    { code: 'WLY01', name: 'Kuala Lumpur & Putrajaya' },
    { code: 'WLY02', name: 'Labuan' },
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  // HH:mm:ss or HH:mm → HH:MM (drop seconds)
  function normalizeTime(t) {
    if (!t) return '';
    const parts = t.split(':');
    return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
  }

  // "01-Jan-2026" → "2026-01-01"
  const MONTH_MAP = {
    Jan:'01', Feb:'02', Mar:'03', Apr:'04', May:'05', Jun:'06',
    Jul:'07', Aug:'08', Sep:'09', Oct:'10', Nov:'11', Dec:'12',
  };
  function normalizeDate(d) {
    // API returns "01-Jan-2026" format
    const [day, mon, year] = d.split('-');
    return `${year}-${MONTH_MAP[mon] ?? '01'}-${day.padStart(2, '0')}`;
  }

  // Fetch one zone's full year with retry — GET with period=year
  async function fetchZone(zone) {
    const url = `${API}&zone=${zone.code}&period=year`;

    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const res = await fetch(url);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const json = await res.json();
        if (json.status !== 'OK!' || !Array.isArray(json.prayerTime)) {
          throw new Error(`Bad response: ${json.status}`);
        }

        return json.prayerTime;

      } catch (err) {
        const wait = attempt * 5000;
        console.warn(`[malaysia_fetch] ${zone.code} attempt ${attempt} failed: ${err.message} — retrying in ${wait/1000}s`);
        if (attempt < 3) await sleep(wait);
      }
    }
    return null;
  }

  // ── Main ──────────────────────────────────────────────────────────────────

  const rows   = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha'];
  const errors = [];

  console.log(`[malaysia_fetch] Starting: ${ZONES.length} zones for ${YEAR}`);

  for (let i = 0; i < ZONES.length; i++) {
    const zone = ZONES[i];
    const data = await fetchZone(zone);

    if (!data) {
      errors.push(zone.code);
      console.warn(`[malaysia_fetch] [${i + 1}/${ZONES.length}] ${zone.code}: FAILED — skipping`);
      continue;
    }

    let count = 0;
    for (const d of data) {
      rows.push([
        zone.name,
        normalizeDate(d.date),   // "01-Jan-2026" → "2026-01-01"
        normalizeTime(d.fajr),
        normalizeTime(d.syuruk),
        normalizeTime(d.dhuhr),
        normalizeTime(d.asr),
        normalizeTime(d.maghrib),
        normalizeTime(d.isha),
      ].join(','));
      count++;
    }

    console.log(`[malaysia_fetch] [${i + 1}/${ZONES.length}] ${zone.name}: ${count} days`);
    await sleep(DELAY_MS);
  }

  if (errors.length) console.warn('[malaysia_fetch] Failed zones:', errors);

  // ── Download CSV ──────────────────────────────────────────────────────────
  const csv      = rows.join('\n') + '\n';
  const filename = `malaysia_prayer_times_${YEAR}.csv`;

  const blob = new Blob([csv], { type: 'text/csv' });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement('a');
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click();
  setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 1000);

  console.log(`[malaysia_fetch] ✅ Done! ${rows.length - 1} rows → ${filename}`);
  console.log('[malaysia_fetch] Next: copy to assets/csv/ then run: dart run tool/csv_to_sqlite.dart');
})();
