"""uq_fetch.py — pull OFFICIAL Saudi prayer times from ummulqura.org.sa.

Source: yearprayer.aspx (one GET = one full Hijri year for one city).
Each city's coordinates come from tool/uq_saudi_cities.json (see uq_harvest_cities.py).
Which cities to ship come from tool/uq_city_map.json — { EnglishCsvName: srcArabicForCoords }:

    { "Mecca": "مكة المكرمة", "Riyadh": "الرياض", ... }   # English CSV name -> Arabic key for coords

For each city it fetches the Hijri years that cover the wanted Gregorian range,
converts the 12-hour times to 24-hour, maps each row's Gregorian date, filters to
[START, END], dedups, and writes assets/csv/saudi_prayer_times_2026.csv.

Usage:  python tool/uq_fetch.py
"""
import re, os, json, time, math, urllib.request, urllib.parse

CITIES_FILE = "tool/uq_saudi_cities.json"
MAP_FILE = "tool/uq_city_map.json"
PROGRESS = "tool/_uq_progress.json"   # resume cache; deleted on a fully clean run
OUT_CSV = "assets/csv/saudi_prayer_times_2026.csv"
HIJRI_YEARS = [1447, 1448]          # cover Gregorian 2026 .. mid-2027
START, END = (2026, 1, 1), (2027, 6, 30)   # inclusive Gregorian filter
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"
BASE = "https://www.ummulqura.org.sa/yearprayer.aspx"

AR_MON = {"يناير": 1, "فبراير": 2, "مارس": 3, "إبريل": 4, "أبريل": 4, "ابريل": 4,
          "مايو": 5, "يونيو": 6, "يوليو": 7, "أغسطس": 8, "اغسطس": 8,
          "سبتمبر": 9, "أكتوبر": 10, "اكتوبر": 10, "نوفمبر": 11, "ديسمبر": 12}


def greg_start_year(hijri):
    """Gregorian year in which 1 Muharram <hijri> falls (verified for 1446-1450)."""
    return math.floor(hijri * 0.970229 + 621.567)


def to24(t, kind):
    """12-hour clock -> 24-hour. Fajr/Sunrise/Dhuhr stay AM; Asr/Maghrib/Isha are PM."""
    h, m = (int(x) for x in t.split(":"))
    if kind in ("asr", "maghrib", "isha") and h != 12:
        h += 12
    return f"{h:02d}:{m:02d}"


def cells(row):
    return [re.sub(r"<[^>]+>", "", c).strip() for c in re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", row, re.S)]


def fetch_year(lon, lat, tz, hijri, city_ar):
    url = BASE + "?" + urllib.parse.urlencode(
        {"l": lon, "m": lat, "t": tz, "year": str(hijri), "day": "1", "city": city_ar})
    req = urllib.request.Request(url, headers={
        "User-Agent": UA, "Referer": "https://www.ummulqura.org.sa/index.aspx?tab=prayertimes"})
    last = None
    for attempt in range(5):
        try:
            return urllib.request.urlopen(req, timeout=90).read().decode("utf-8", "replace")
        except Exception as e:  # connection reset / timeout / 5xx — back off and retry
            last = e
            time.sleep(3 * (attempt + 1))
    raise last


def parse_year(html, hijri):
    """Return list of (y, m, d, fajr, sunrise, dhuhr, asr, maghrib, isha) in 24h."""
    cur_month, cur_year, out = None, greg_start_year(hijri), []
    for tbl in re.findall(r"<table.*?</table>", html, re.S):
        rows = [cells(r) for r in re.findall(r"<tr[^>]*>.*?</tr>", tbl, re.S)]
        data = [r for r in rows if len(r) == 8 and re.match(r"^\d+$", r[0]) and re.match(r"\d\d:\d\d", r[-1])]
        for r in data:
            greg = r[1]
            mname = re.search(r"([؀-ۿ]+)", greg)
            dnum = re.search(r"(\d+)", greg)
            if mname and mname.group(1) in AR_MON:
                nm = AR_MON[mname.group(1)]
                if cur_month is not None and nm < cur_month:
                    cur_year += 1
                cur_month = nm
            if cur_month is None or not dnum:
                continue
            day = int(dnum.group(1))
            out.append((cur_year, cur_month, day,
                        to24(r[2], "fajr"), to24(r[3], "sunrise"), to24(r[4], "dhuhr"),
                        to24(r[5], "asr"), to24(r[6], "maghrib"), to24(r[7], "isha")))
    return out


def in_range(y, m, d):
    return START <= (y, m, d) <= END


def fetch_city(en_name, c, ar_name):
    """All wanted Gregorian days for one city, deduped across Hijri years."""
    seen = {}
    for hy in HIJRI_YEARS:
        html = fetch_year(c["lon"], c["lat"], c["tz"], hy, ar_name)
        for y, m, d, f, s, z, a, mg, i in parse_year(html, hy):
            if in_range(y, m, d):
                seen[(y, m, d)] = (f"{y:04d}-{m:02d}-{d:02d}", f, s, z, a, mg, i)
        time.sleep(0.5)
    return [f"{en_name},{seen[k][0]},{','.join(seen[k][1:])}" for k in sorted(seen)]


def main():
    coords = {c["ar"]: c for c in json.load(open(CITIES_FILE, encoding="utf-8"))}
    city_map = json.load(open(MAP_FILE, encoding="utf-8"))  # {English: srcArabic for coords}
    # Resume support: keep already-fetched cities from a previous (partial) run.
    done = {}
    if os.path.exists(PROGRESS):
        done = json.load(open(PROGRESS, encoding="utf-8"))
        print(f"Resuming: {len(done)} cities already fetched")
    print(f"{len(city_map)} cities x {len(HIJRI_YEARS)} Hijri years\n")

    failed = []
    todo = [(e, a) for e, a in city_map.items() if e not in done]
    for n, (en_name, ar_name) in enumerate(todo, 1):
        c = coords.get(ar_name)
        if not c:
            failed.append(en_name); print(f"  [{n}/{len(todo)}] SKIP {en_name}: no coords"); continue
        try:
            city_rows = fetch_city(en_name, c, ar_name)
            if not city_rows:
                failed.append(en_name); print(f"  [{n}/{len(todo)}] SKIP {en_name}: 0 days"); continue
            done[en_name] = city_rows
            json.dump(done, open(PROGRESS, "w", encoding="utf-8"), ensure_ascii=False)
            print(f"  [{n}/{len(todo)}] OK  {en_name}: {len(city_rows)} days "
                  f"[{city_rows[0].split(',')[1]} .. {city_rows[-1].split(',')[1]}]")
        except Exception as e:
            failed.append(en_name); print(f"  [{n}/{len(todo)}] FAIL {en_name}: {e}")

    rows = ["City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha"]
    for en in sorted(done):
        rows.extend(done[en])
    open(OUT_CSV, "w", encoding="utf-8", newline="").write("\n".join(rows) + "\n")
    print(f"\nWrote {len(rows)-1} rows for {len(done)} cities to {OUT_CSV}")
    if failed:
        print(f"FAILED ({len(failed)}): {failed}\n  re-run to retry just these (progress is cached).")
    else:
        os.path.exists(PROGRESS) and os.remove(PROGRESS)
        print("Next: dart run tool/csv_to_json.dart")


if __name__ == "__main__":
    main()
