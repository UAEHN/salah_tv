# -*- coding: utf-8 -*-
"""
build_kuwait_csv.py — Build the multi-city Kuwait prayer-times CSV from the
official Al-Ojeiri Kuwait City table + per-region minute offsets.

Inputs  (relative to project root):
  tool/alojeiri_kuwait_base_2026.csv   Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha
  tool/kuwait_regions.json             [{en, ar, offset, existing?}]

Output:
  assets/csv/kuwait_prayer_times_2026.csv   City,Date,Fajr,...,Isha (all regions)

The offset is added uniformly to all six prayers, then re-formatted HH:MM.
Run:  python tool/build_kuwait_csv.py
Then: dart run tool/csv_to_json.dart
"""
import json, csv, io, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(ROOT, 'tool', 'alojeiri_kuwait_base_2026.csv')
REGIONS = os.path.join(ROOT, 'tool', 'kuwait_regions.json')
OUT = os.path.join(ROOT, 'assets', 'csv', 'kuwait_prayer_times_2026.csv')

PRAYERS = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']


def shift(hhmm, off):
    h, m = hhmm.split(':')
    total = (int(h) * 60 + int(m) + off) % (24 * 60)
    return f"{total // 60:02d}:{total % 60:02d}"


def main():
    with io.open(BASE, encoding='utf-8-sig', newline='') as f:
        base_rows = list(csv.DictReader(f))
    with io.open(REGIONS, encoding='utf-8') as f:
        regions = json.load(f)['regions']

    # Guard: base must be a full year, no gaps, all cells present.
    assert len(base_rows) >= 365, f"base has only {len(base_rows)} rows"
    for r in base_rows:
        for p in PRAYERS:
            assert r[p], f"empty {p} on {r['Date']}"

    out_lines = ['City,Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha']
    seen = set()
    for reg in regions:
        name, off = reg['en'], reg['offset']
        assert name not in seen, f"duplicate region {name}"
        seen.add(name)
        for r in base_rows:
            vals = [shift(r[p], off) for p in PRAYERS]
            out_lines.append(','.join([name, r['Date']] + vals))

    with io.open(OUT, 'w', encoding='utf-8', newline='') as f:
        f.write('\n'.join(out_lines) + '\n')

    print(f"OK  {len(regions)} regions x {len(base_rows)} days "
          f"= {len(out_lines) - 1} rows -> {OUT}")
    # spot-check a few offsets vs base on one date
    sample_date = '15/06/2026'
    base = next(r for r in base_rows if r['Date'] == sample_date)
    print(f"  base   {sample_date}  Fajr={base['Fajr']} Maghrib={base['Maghrib']}")
    for nm in ['Al Jahra', 'Al Fahaheel', 'Al Salmi', 'Qaruh']:
        reg = next(r for r in regions if r['en'] == nm)
        print(f"  {nm:14s} off={reg['offset']:+d}  "
              f"Fajr={shift(base['Fajr'], reg['offset'])} "
              f"Maghrib={shift(base['Maghrib'], reg['offset'])}")


if __name__ == '__main__':
    main()
