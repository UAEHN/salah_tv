"""uq_harvest_cities.py — one-time harvest of Saudi city coordinates from
ummulqura.org.sa.

For each city in the prayer-times dropdown it performs the 'عرض أوقات الصلاة'
postback, then reads the coordinates (lon/lat/tz) out of the 'اطبع سنة'
(yearprayer.aspx) button URL. Saves tool/uq_saudi_cities.json:

  [{"id": "21", "ar": "مكة المكرمة", "lon": "39.83", "lat": "21.42", "tz": "3.00"}, ...]

Run once:  python tool/uq_harvest_cities.py
The fetch script (uq_fetch.py) reuses this file and never needs the postback.
"""
import re, json, time, urllib.request, urllib.parse, http.cookiejar

BASE = "https://www.ummulqura.org.sa/index.aspx?tab=prayertimes"
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"
P = "ctl00$ContentPlaceHolder1$KACSTPrayerControl1$"
OUT = "tool/uq_saudi_cities.json"


def new_session():
    cj = http.cookiejar.CookieJar()
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    op.addheaders = [("User-Agent", UA)]
    return op


def hidden(html, name):
    m = re.search(r'id="' + name + r'"[^>]*value="([^"]*)"', html)
    return m.group(1) if m else ""


def parse_cities(html):
    m = re.search(r'name="[^"]*ddlCities"[^>]*>(.*?)</select>', html, re.S)
    return re.findall(r'<option[^>]*value="([^"]*)"[^>]*>([^<]*)', m.group(1)) if m else []


def show_city(op, vs, vg, ev, city_id):
    """Full Button1 postback for a city; return yearprayer URL params."""
    form = {
        "__EVENTTARGET": "", "__EVENTARGUMENT": "", "__LASTFOCUS": "",
        "__VIEWSTATE": vs, "__VIEWSTATEGENERATOR": vg, "__EVENTVALIDATION": ev,
        f"{P}ddlCountries": "1", f"{P}ddlCities": city_id,
        f"{P}ddlDays": "1", f"{P}ddlMonths": "1", f"{P}ddlYears": "1448",
        f"{P}a": "RadioButton1", f"{P}hour": "RadioButton3",
        f"{P}Button1": "عرض أوقات الصلاة",
    }
    data = urllib.parse.urlencode(form, encoding="utf-8").encode()
    req = urllib.request.Request(BASE, data=data, headers={
        "Content-Type": "application/x-www-form-urlencoded", "Referer": BASE})
    resp = op.open(req, timeout=60).read().decode("utf-8", "replace")
    m = re.search(r'yearprayer\.aspx\?l=([\d.\-]+)&(?:amp;)?m=([\d.\-]+)&(?:amp;)?t=([\d.\-]+)', resp)
    return m.groups() if m else None


def main():
    op = new_session()
    html = op.open(BASE, timeout=60).read().decode("utf-8", "replace")
    vs, vg, ev = hidden(html, "__VIEWSTATE"), hidden(html, "__VIEWSTATEGENERATOR"), hidden(html, "__EVENTVALIDATION")
    cities = parse_cities(html)
    print(f"{len(cities)} cities found. Harvesting coordinates...")

    out, fails = [], []
    for i, (cid, name) in enumerate(cities, 1):
        name = name.strip()
        try:
            coords = show_city(op, vs, vg, ev, cid)
            if not coords:
                fails.append((cid, name)); print(f"  [{i}/{len(cities)}] {name} ({cid}) -> NO COORDS"); continue
            lon, lat, tz = coords
            out.append({"id": cid, "ar": name, "lon": lon, "lat": lat, "tz": tz})
            print(f"  [{i}/{len(cities)}] {name} ({cid}) -> lon={lon} lat={lat} tz={tz}")
        except Exception as e:
            fails.append((cid, name)); print(f"  [{i}/{len(cities)}] {name} ({cid}) -> ERROR {e}")
        time.sleep(0.25)

    json.dump(out, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print(f"\nSaved {len(out)} cities to {OUT}. Failures: {len(fails)}")
    if fails:
        print("  retry these later:", fails)


if __name__ == "__main__":
    main()
