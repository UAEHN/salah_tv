# -*- coding: utf-8 -*-
"""
update_kuwait_catalog.py — Register every Kuwait region from tool/kuwait_regions.json
into the app's bundled catalog so they appear in the city picker.

Updates (in place, preserving everything else):
  assets/db_city_lists.json   kuwait: [English names...]  (sorted, unique)
  assets/db_countries.json    cities: { "English name": "Arabic name", ... }

Run:  python tool/update_kuwait_catalog.py
"""
import json, io, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGIONS = os.path.join(ROOT, 'tool', 'kuwait_regions.json')
CITY_LISTS = os.path.join(ROOT, 'assets', 'db_city_lists.json')
COUNTRIES = os.path.join(ROOT, 'assets', 'db_countries.json')


def load(p):
    with io.open(p, encoding='utf-8') as f:
        return json.load(f)


def dump(p, data):
    with io.open(p, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def main():
    regions = load(REGIONS)['regions']
    names_en = [r['en'] for r in regions]
    ar_by_en = {r['en']: r['ar'] for r in regions}

    # 1) db_city_lists.json — replace kuwait array with the full sorted set.
    cl = load(CITY_LISTS)
    before = len(cl.get('kuwait', []))
    cl['kuwait'] = sorted(names_en)
    dump(CITY_LISTS, cl)
    print(f"db_city_lists.json: kuwait {before} -> {len(cl['kuwait'])} cities")

    # 2) db_countries.json — add/refresh Arabic name for each region.
    dc = load(COUNTRIES)
    cities = dc['cities']
    added = updated = 0
    for en, ar in ar_by_en.items():
        if en not in cities:
            added += 1
        elif cities[en] != ar:
            updated += 1
        cities[en] = ar
    dump(COUNTRIES, dc)
    print(f"db_countries.json: +{added} new arabic names, {updated} updated, "
          f"{len(cities)} total")


if __name__ == '__main__':
    main()
