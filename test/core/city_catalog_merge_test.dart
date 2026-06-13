import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/city_translations.dart';
import 'package:ghasaq/core/remote_city_catalog.dart';

void main() {
  group('mergeRemoteCatalog', () {
    setUp(() {
      // Bundled baseline: Oman with two cities (Arabic resolved elsewhere).
      registerDbCountries({
        'oman': ['Muscat', 'Salalah'],
      });
    });

    test('adds a newly-published city to an existing country', () {
      mergeRemoteCatalog(
        const RemoteCityCatalog(
          version: 1,
          countries: [
            RemoteCatalogCountry(
              key: 'oman',
              arabicName: 'عُمان',
              englishName: 'Oman',
              cities: [
                RemoteCatalogCity(englishName: 'Muscat', arabicName: 'مسقط'),
                RemoteCatalogCity(englishName: 'Barka', arabicName: 'بركاء'),
              ],
            ),
          ],
        ),
      );

      final oman = kCountries.firstWhere((c) => c.key == 'oman');
      expect(oman.cities, contains('Barka'));
      expect(oman.cities, contains('Salalah')); // bundled city preserved
      expect(cityLabel('Barka'), 'بركاء'); // remote Arabic filled in
    });

    test('registers a country the catalog introduces, with labels', () {
      mergeRemoteCatalog(
        const RemoteCityCatalog(
          version: 1,
          countries: [
            RemoteCatalogCountry(
              key: 'qatar',
              arabicName: 'قطر',
              englishName: 'Qatar',
              cities: [
                RemoteCatalogCity(englishName: 'Doha', arabicName: 'الدوحة'),
              ],
            ),
          ],
        ),
      );

      expect(kDbCountryKeys, contains('qatar'));
      expect(countryLabel('qatar'), 'قطر');
      final qatar = kCountries.firstWhere((c) => c.key == 'qatar');
      expect(qatar.cities, contains('Doha'));
    });

    test(
      'is additive — never removes a bundled city absent from the catalog',
      () {
        mergeRemoteCatalog(
          const RemoteCityCatalog(
            version: 1,
            countries: [
              RemoteCatalogCountry(
                key: 'oman',
                arabicName: 'عُمان',
                englishName: 'Oman',
                cities: [
                  RemoteCatalogCity(englishName: 'Barka', arabicName: 'بركاء'),
                ],
              ),
            ],
          ),
        );

        final oman = kCountries.firstWhere((c) => c.key == 'oman');
        expect(oman.cities, containsAll(['Muscat', 'Salalah', 'Barka']));
      },
    );
  });
}
