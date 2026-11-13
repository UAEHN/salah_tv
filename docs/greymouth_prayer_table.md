# Greymouth annual prayer timetable

For existing apps, the remote city catalog temporarily lists the section as
**Greymouth – New Zealand / غريموث – نيوزيلندا**. This distinguishes the supplied
table from the bundled calculated New Zealand section. The original New Zealand
country and its other cities remain available. The next app update can use the
section's `iso: NZ` and canonical country labels to merge them in one country.
The downloadable table is `new_zealand/greymouth.json`, generated from
`assets/csv/new_zealand_prayer_times_2027.csv` by the existing prayer-data workflow.
Clients with remote city-catalog support discover it when the catalog refreshes;
they do not need a new APK to download the table.

The temporary section title is configured in `assets/city_catalog_overrides.json`.
The download identity and URL stay unchanged, preserving existing selections.
Existing apps can retain the old country title for the current session; restart
after the fresh catalog has been cached to load the revised title.

All 365 dates from 1 January through 31 December 2027 are copied from the supplied
`Greymouth_Prayer_Timetable_2027_ISNA_Hanafi.xlsx`. The six columns are Fajr,
sunrise, Dhuhr, Asr, Maghrib and Isha. Times are rounded from Excel day fractions
to their original whole minutes; no prayer is recalculated or shifted.

The source convention is **ISNA / North America, Hanafi Asr**, with local
**Pacific/Auckland** clock times. North America names the calculation method;
it is not the city's timezone. The table already includes the one-hour changes
on 4 April and 26 September 2027. Do not apply another DST or Hanafi correction.
The published client reads downloaded table rows unchanged. Devices using this
table should have their system clock/timezone set correctly for New Zealand.

This is a supplied calculated timetable, not a claim of approval by a local mosque.
It covers 2027. The client's month/day fallback outside the stored year does not
account for a different year's DST dates, so publish that year's own schedule
before relying on this location outside 2027.

The workbook and its importer remain in the author's workspace. Before
publication, all 2,190 times in the generated download were compared with the
workbook. The existing published city hashes and catalog entries were also
verified to be unchanged.
