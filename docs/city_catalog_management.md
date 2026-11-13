# Remote city catalog management

`assets/city_catalog_overrides.json` controls catalog entries without changing
prayer rows. The prayer-data workflow publishes it whenever the file changes.
The `v: 1` transport remains readable by existing apps; new management fields
take effect in the next app version, after that version is installed once.

Country keys and city `id`/`en` values are stable identities, not display labels.
Use `iso` to group table and calculated entries under the same country. Use
`countryAr`/`countryEn` for its canonical title; `ar`/`en` at country level can
retain a distinct section title for older apps. Keep download country/city
identities unchanged so selected locations and cached data keep working.

Within `countries.<key>.cities`, a patch matches an existing city's `id`, `slug`,
or canonical `en`. Override `ar` or `labelEn` to rename the displayed city.
Set `hidden: true` or `deleted: true` to remove it from new selections, including
bundled fallback entries. Retain a tombstone when a bundled city must stay
removed. A removed remote-only entry otherwise disappears on the next snapshot.
Set country `hidden`/`deleted` to hide the country, or `replaceCities: true` to
publish its complete allowed list instead of retaining its bundled cities.

Add a table using the existing CSV pipeline. Add a calculated city with
`source: calculated`, `id`, `en`, `ar`, `lat`, `lng`, `method`, `timeZoneId`,
and `utcOffsetHours`; optional `madhab` defaults to the user's setting.
The time-zone identifier is authoritative across daylight-saving changes.

Hiding/deleting affects the picker. It does not erase an already selected city's
download or change a device's location automatically. The last valid catalog is
cached for offline use; invalid fetches must not replace that cache. Changes
appear when the app next refreshes its catalog and the location picker reloads.

For the temporary Greymouth section, the old and new apps both download
`new_zealand/greymouth.json`. Existing apps show its distinct legacy title. The
updated picker will show one New Zealand country containing both its calculated
cities and the supplied Greymouth table.
