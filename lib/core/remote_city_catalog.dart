/// Transport types for a remotely-published city catalog
/// (`prayer_data/catalog.json`). Defined in `core/` so [mergeRemoteCatalog]
/// (in city_translations.dart) stays dependency-free — the settings data layer
/// builds these from the parsed JSON and hands them to the merge.
class RemoteCityCatalog {
  final int version;
  final List<RemoteCatalogCountry> countries;

  const RemoteCityCatalog({required this.version, required this.countries});
}

class RemoteCatalogCountry {
  final String key; // lowercase country key (e.g. "oman")
  final String arabicName;
  final String englishName;
  final List<RemoteCatalogCity> cities;

  const RemoteCatalogCountry({
    required this.key,
    required this.arabicName,
    required this.englishName,
    required this.cities,
  });
}

class RemoteCatalogCity {
  final String englishName; // canonical city identity (slug derives from this)
  final String arabicName; // falls back to englishName when not yet translated

  const RemoteCatalogCity({
    required this.englishName,
    required this.arabicName,
  });
}
