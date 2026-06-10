import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/settings/domain/entities/online_geocoding_result.dart';
import 'package:ghasaq/features/settings/domain/i_online_geocoding_repository.dart';
import 'package:ghasaq/features/settings/presentation/bloc/online_geocoding_cubit.dart';

class _FakeRepo implements IOnlineGeocodingRepository {
  _FakeRepo(this._next);
  Either<Failure, List<OnlineGeocodingResult>> _next;
  String? lastQuery;
  String? lastCountryCode;
  int calls = 0;

  set next(Either<Failure, List<OnlineGeocodingResult>> v) => _next = v;

  @override
  Future<Either<Failure, List<OnlineGeocodingResult>>> search(
    String q, {
    String? countryCode,
  }) async {
    calls++;
    lastQuery = q;
    lastCountryCode = countryCode;
    return _next;
  }

  @override
  Future<Either<Failure, OnlineGeocodingResult?>> reverse({
    required double latitude,
    required double longitude,
    String? localeHint,
  }) async => const Right(null);
}

const _berlin = OnlineGeocodingResult(
  name: 'Berlin',
  displayName: 'Berlin, Germany',
  latitude: 52.52,
  longitude: 13.4,
  countryCode: 'DE',
  countryName: 'Germany',
);

void main() {
  group('OnlineGeocodingCubit', () {
    test('skips repo for queries shorter than 2 chars', () async {
      final repo = _FakeRepo(const Right([]));
      final cubit = OnlineGeocodingCubit(repo);

      cubit.searchDebounced('a');
      await Future.delayed(const Duration(milliseconds: 600));

      expect(repo.calls, 0);
      expect(cubit.state.status, OnlineGeocodingStatus.idle);
      await cubit.close();
    });

    test(
      'emits loading then results on a successful debounced search',
      () async {
        final repo = _FakeRepo(const Right([_berlin]));
        final cubit = OnlineGeocodingCubit(repo);

        cubit.searchDebounced('Berlin');
        expect(cubit.state.status, OnlineGeocodingStatus.loading);
        await Future.delayed(const Duration(milliseconds: 600));

        expect(repo.calls, 1);
        expect(repo.lastQuery, 'Berlin');
        expect(cubit.state.status, OnlineGeocodingStatus.results);
        expect(cubit.state.results, [_berlin]);
        await cubit.close();
      },
    );

    test('emits empty when repo returns []', () async {
      final repo = _FakeRepo(const Right([]));
      final cubit = OnlineGeocodingCubit(repo);

      cubit.searchDebounced('Atlantis');
      await Future.delayed(const Duration(milliseconds: 600));

      expect(cubit.state.status, OnlineGeocodingStatus.empty);
      await cubit.close();
    });

    test('emits error on failure', () async {
      final repo = _FakeRepo(const Left(NetworkFailure('boom')));
      final cubit = OnlineGeocodingCubit(repo);

      cubit.searchDebounced('Berlin');
      await Future.delayed(const Duration(milliseconds: 600));

      expect(cubit.state.status, OnlineGeocodingStatus.error);
      expect(cubit.state.error, 'boom');
      await cubit.close();
    });

    test('forwards countryCode bias to repo', () async {
      final repo = _FakeRepo(const Right([_berlin]));
      final cubit = OnlineGeocodingCubit(repo);

      cubit.searchDebounced('Berlin', countryCode: 'DE');
      await Future.delayed(const Duration(milliseconds: 600));

      expect(repo.calls, 1);
      expect(repo.lastQuery, 'Berlin');
      expect(repo.lastCountryCode, 'DE');
      await cubit.close();
    });

    test(
      'debounces rapid keystrokes — only the last query hits the repo',
      () async {
        final repo = _FakeRepo(const Right([_berlin]));
        final cubit = OnlineGeocodingCubit(repo);

        cubit.searchDebounced('Be');
        cubit.searchDebounced('Berl');
        cubit.searchDebounced('Berlin');
        await Future.delayed(const Duration(milliseconds: 600));

        expect(repo.calls, 1);
        expect(repo.lastQuery, 'Berlin');
        await cubit.close();
      },
    );
  });
}
