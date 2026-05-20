import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/today/domain/entities/daily_verse.dart';
import 'package:ghasaq/features/today/domain/entities/upcoming_occasion.dart';
import 'package:ghasaq/features/today/domain/i_daily_verse_repository.dart';
import 'package:ghasaq/features/today/domain/i_islamic_occasions_repository.dart';
import 'package:ghasaq/features/today/domain/usecases/get_current_greeting.dart';
import 'package:ghasaq/features/today/domain/usecases/get_daily_verse.dart';
import 'package:ghasaq/features/today/domain/usecases/get_upcoming_occasion.dart';
import 'package:ghasaq/features/today/presentation/bloc/today_cubit.dart';
import 'package:ghasaq/features/today/presentation/bloc/today_state.dart';

class _StubVerseRepo implements IDailyVerseRepository {
  final DailyVerse? verse;
  final Failure? failure;
  const _StubVerseRepo({this.verse, this.failure});

  @override
  Future<Either<Failure, DailyVerse>> getVerseForDay(DateTime now) async {
    if (failure != null) return Left(failure!);
    return Right(verse!);
  }
}

class _StubOccasionRepo implements IIslamicOccasionsRepository {
  final UpcomingOccasion? occasion;
  final Failure? failure;
  const _StubOccasionRepo({this.occasion, this.failure});

  @override
  Future<Either<Failure, UpcomingOccasion?>> getNextOccasion(
    DateTime from,
  ) async {
    if (failure != null) return Left(failure!);
    return Right(occasion);
  }
}

TodayCubit _buildCubit({
  IDailyVerseRepository? verseRepo,
  IIslamicOccasionsRepository? occasionRepo,
}) {
  return TodayCubit(
    getGreeting: const GetCurrentGreetingUseCase(),
    getOccasion: GetUpcomingOccasionUseCase(
      occasionRepo ?? const _StubOccasionRepo(occasion: null),
    ),
    getVerse: GetDailyVerseUseCase(
      verseRepo ?? const _StubVerseRepo(failure: CacheFailure('no verse')),
    ),
  );
}

void main() {
  group('TodayCubit', () {
    test('load → emits Loaded with all sections populated', () async {
      const verse = DailyVerse(
        surahNumber: 1,
        ayahNumber: 1,
        textAr: 'بسم الله',
      );
      const occasion = UpcomingOccasion(
        id: 'ramadan_start',
        labelKey: 'occasionRamadanStart',
        hijriMonth: 9,
        hijriDay: 1,
        daysUntil: 12,
      );
      final cubit = _buildCubit(
        verseRepo: const _StubVerseRepo(verse: verse),
        occasionRepo: const _StubOccasionRepo(occasion: occasion),
      );

      await cubit.load(now: DateTime(2026, 5, 7, 9));

      expect(cubit.state, isA<TodayLoaded>());
      final loaded = cubit.state as TodayLoaded;
      expect(loaded.upcomingOccasion, occasion);
      expect(loaded.dailyVerse, verse);
      expect(loaded.hasPartialFailure, isFalse);

      await cubit.close();
    });

    test('load → marks partial when verse fails (occasion still loads)',
        () async {
      const occasion = UpcomingOccasion(
        id: 'eid_fitr',
        labelKey: 'occasionEidFitr',
        hijriMonth: 10,
        hijriDay: 1,
        daysUntil: 5,
      );
      final cubit = _buildCubit(
        verseRepo: const _StubVerseRepo(failure: CacheFailure('boom')),
        occasionRepo: const _StubOccasionRepo(occasion: occasion),
      );

      await cubit.load(now: DateTime(2026, 5, 7, 9));

      final loaded = cubit.state as TodayLoaded;
      expect(loaded.dailyVerse, isNull);
      expect(loaded.upcomingOccasion, occasion);
      expect(loaded.hasPartialFailure, isTrue);

      await cubit.close();
    });

    test('refreshGreeting → no emit when period unchanged', () async {
      final cubit = _buildCubit();

      await cubit.load(now: DateTime(2026, 5, 7, 9));
      final before = cubit.state;
      cubit.refreshGreeting(now: DateTime(2026, 5, 7, 9, 30));
      expect(cubit.state, equals(before));

      await cubit.close();
    });
  });
}
