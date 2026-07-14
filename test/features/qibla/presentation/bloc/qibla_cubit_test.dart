import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/qibla/domain/entities/qibla_data.dart';
import 'package:ghasaq/features/qibla/domain/i_qibla_repository.dart';
import 'package:ghasaq/features/qibla/presentation/bloc/qibla_cubit.dart';
import 'package:ghasaq/features/qibla/presentation/bloc/qibla_state.dart';

/// Feeds the cubit a controlled Qibla stream so we can assert failure routing.
class _FakeQiblaRepo implements IQiblaRepository {
  final _controller = StreamController<Either<Failure, QiblaData>>.broadcast();

  void push(Either<Failure, QiblaData> event) => _controller.add(event);

  @override
  Stream<Either<Failure, QiblaData>> watchQibla() => _controller.stream;

  @override
  void pauseSensors() {}

  @override
  void resumeSensors() {}

  @override
  Future<void> dispose() async => _controller.close();
}

void main() {
  group('QiblaCubit failure routing', () {
    test('SensorUnavailableFailure → QiblaSensorUnavailable (no crash)', () async {
      final repo = _FakeQiblaRepo();
      final cubit = QiblaCubit(repo)..start();
      final done = expectLater(
        cubit.stream,
        emitsThrough(isA<QiblaSensorUnavailable>()),
      );

      repo.push(const Left(SensorUnavailableFailure()));

      await done;
      await cubit.close();
    });

    test('LocationPermissionFailure → QiblaPermissionDenied', () async {
      final repo = _FakeQiblaRepo();
      final cubit = QiblaCubit(repo)..start();
      final done = expectLater(
        cubit.stream,
        emitsThrough(isA<QiblaPermissionDenied>()),
      );

      repo.push(const Left(LocationPermissionFailure()));

      await done;
      await cubit.close();
    });

    test('QiblaData → QiblaActive', () async {
      final repo = _FakeQiblaRepo();
      final cubit = QiblaCubit(repo)..start();
      final done = expectLater(
        cubit.stream,
        emitsThrough(isA<QiblaActive>()),
      );

      repo.push(
        const Right(
          QiblaData(qiblaBearing: 258, deviceHeading: 0, distanceKm: 1500),
        ),
      );

      await done;
      await cubit.close();
    });
  });
}
