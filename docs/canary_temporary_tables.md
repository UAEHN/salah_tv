# Temporary Canary Islands prayer tables

Published on 25 October 2026 to provide correct local prayer times to existing
clients while the calculated-location timezone correction awaits an app update.
The remote catalog labels this region **Canary Islands (temporary)** /
**جزر الكناري (جدول مؤقت)**. Select the island and named city in the location
picker: **Pajara - Fuerteventura** / **باخارا - فويرتيفنتورا**. Selecting the
existing calculated Spain entry does not use this table.

These are calculated schedules, not an official mosque timetable. They use the
app's existing adhan_dart 1.2.0 Muslim World League/Shafi convention, with no
additional manual minute adjustments. Users keep their existing prayer offsets
and madhab setting. Each row represents the named city's coordinates; it is not
an island-wide or archipelago-wide timetable.

All dates in 2026 are included, using IANA **Atlantic/Canary** for each prayer's
actual date: UTC+1 in summer and UTC+0 in winter, including the 25 October
transition. Do not apply a second one-hour adjustment to these tables.

The location is Pájara on Fuerteventura: latitude 28.35039, longitude -14.1076,
GeoNames ID 2513026, recorded in `tool/build_canary_temporary_tables.dart`.
Coordinates and timezone identifiers
come from the [GeoNames Spain extract](https://download.geonames.org/export/dump/ES.zip),
retrieved 25 October 2026, licensed under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Spain's [official calendar](https://www.boe.es/buscar/doc.php?id=BOE-A-2022-4026)
sets the 2026 winter transition to 25 October.

Regenerate with `dart run tool/build_canary_temporary_tables.dart` followed by
`dart run tool/csv_to_json.dart`. Publish through the existing prayer-data
workflow. The `IC` label entry identifies the Canary region without changing
Spain's existing `ES` country mapping or its calculated city catalog.

Retain these downloads while users rely on them. After the app correction is
released, users may return to their precise calculated location. If still needed
in 2027, generate a schedule for that year using its own timezone transitions;
the client's same-month/day fallback is not a DST calendar for another year.
