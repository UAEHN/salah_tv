import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/settings/data/datasources/city_catalog_remote_data_source.dart';

void main() {
  group('CityCatalogRemoteDataSource.parse', () {
    test('parses countries and cities, falling back Arabic → English', () {
      const body = '''
        { "v": 1, "generated": "2026-06-13", "countries": {
            "oman": { "ar": "عُمان", "en": "Oman", "cities": [
              { "slug": "muscat", "en": "Muscat", "ar": "مسقط" },
              { "slug": "barka",  "en": "Barka",  "ar": "Barka" }
            ] } } }
      ''';

      final catalog = CityCatalogRemoteDataSource.parse(body);

      expect(catalog.version, 1);
      expect(catalog.countries, hasLength(1));
      final oman = catalog.countries.single;
      expect(oman.key, 'oman');
      expect(oman.arabicName, 'عُمان');
      expect(oman.cities, hasLength(2));
      expect(oman.cities.first.englishName, 'Muscat');
      expect(oman.cities.first.arabicName, 'مسقط');
      // Arabic equal to English is kept as-is (English fallback).
      expect(oman.cities.last.arabicName, 'Barka');
    });

    test('skips malformed city entries without throwing', () {
      const body = '''
        { "v": 1, "countries": {
            "oman": { "ar": "عُمان", "en": "Oman", "cities": [
              { "en": "Muscat", "ar": "مسقط" },
              { "ar": "بلا اسم" },
              "garbage"
            ] } } }
      ''';

      final catalog = CityCatalogRemoteDataSource.parse(body);
      expect(catalog.countries.single.cities, hasLength(1));
      expect(catalog.countries.single.cities.single.englishName, 'Muscat');
    });

    test('rejects a future schema version', () {
      const body = '{ "v": 2, "countries": {} }';
      expect(
        () => CityCatalogRemoteDataSource.parse(body),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws on a non-object body', () {
      expect(
        () => CityCatalogRemoteDataSource.parse('[]'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
