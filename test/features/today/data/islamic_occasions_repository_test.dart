import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

import 'package:ghasaq/features/app_update/domain/i_app_version_info_port.dart';
import 'package:ghasaq/features/today/data/datasources/occasions_local_data_source.dart';
import 'package:ghasaq/features/today/data/datasources/occasions_remote_data_source.dart';
import 'package:ghasaq/features/today/data/islamic_occasions_repository_impl.dart';
import 'package:ghasaq/features/today/data/models/remote_occasion_dto.dart';

class _StubVersion implements IAppVersionInfoPort {
  @override
  Future<int> currentBuildNumber() async => 0;
}

class _ThrowingRemote extends OccasionsRemoteDataSource {
  @override
  Future<RemoteOccasionsPayload> fetch() async {
    throw Exception('offline');
  }
}

class _StubLocal extends OccasionsLocalDataSource {
  _StubLocal(this._dtos);

  final List<RemoteOccasionDto> _dtos;

  @override
  Future<List<RemoteOccasionDto>> readCached() async => const [];

  @override
  Future<List<RemoteOccasionDto>> readBundled() async => _dtos;

  @override
  Future<void> writeCache(String rawJson, String? etag) async {}

  @override
  Future<String?> readCachedEtag() async => null;
}

const _testCatalog = <RemoteOccasionDto>[
  RemoteOccasionDto(
    id: 'ramadan_start',
    hijriMonth: 9,
    hijriDay: 1,
    labelAr: 'بداية رمضان',
  ),
  RemoteOccasionDto(
    id: 'eid_fitr',
    hijriMonth: 10,
    hijriDay: 1,
    labelAr: 'عيد الفطر',
  ),
  RemoteOccasionDto(
    id: 'arafah',
    hijriMonth: 12,
    hijriDay: 9,
    labelAr: 'يوم عرفة',
  ),
];

IslamicOccasionsRepositoryImpl _buildRepo() => IslamicOccasionsRepositoryImpl(
      remoteSource: _ThrowingRemote(),
      localSource: _StubLocal(_testCatalog),
      versionInfo: _StubVersion(),
    );

void main() {
  group('IslamicOccasionsRepositoryImpl', () {
    test('returns a Right with non-null when an occasion is within window',
        () async {
      final repo = _buildRepo();
      DateTime probe = DateTime(2026, 1, 1);
      var found = false;
      for (var i = 0; i < 365; i++) {
        final hijri = HijriCalendar.fromDate(probe);
        final match = _testCatalog.any(
          (o) => o.hijriMonth == hijri.hMonth && o.hijriDay == hijri.hDay,
        );
        if (match) {
          found = true;
          break;
        }
        probe = probe.add(const Duration(days: 1));
      }
      expect(found, isTrue, reason: 'catalog should hit within a year');

      final result = await repo.getNextOccasion(probe);
      result.fold((_) => fail('expected Right'), (occasion) {
        expect(occasion, isNotNull);
        expect(occasion!.daysUntil, 0);
      });
    });

    test('daysUntil increases as the start date moves earlier', () async {
      final repo = _buildRepo();
      DateTime probe = DateTime(2026, 1, 1);
      DateTime? hit;
      for (var i = 0; i < 365; i++) {
        final hijri = HijriCalendar.fromDate(probe);
        if (_testCatalog.any(
          (o) => o.hijriMonth == hijri.hMonth && o.hijriDay == hijri.hDay,
        )) {
          hit = probe;
          break;
        }
        probe = probe.add(const Duration(days: 1));
      }
      expect(hit, isNotNull);

      final r1 = await repo.getNextOccasion(
        hit!.subtract(const Duration(days: 1)),
      );
      r1.fold((_) => fail('expected Right'), (o) {
        expect(o!.daysUntil, 1);
      });

      final r3 = await repo.getNextOccasion(
        hit.subtract(const Duration(days: 3)),
      );
      r3.fold((_) => fail('expected Right'), (o) {
        expect(o!.daysUntil, 3);
      });
    });
  });
}
