import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/qibla_data.dart';
import '../domain/i_qibla_repository.dart';
import 'qibla_math.dart';

class QiblaRepository implements IQiblaRepository {
  StreamController<Either<Failure, QiblaData>>? _controller;
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  double? _qiblaBearing;
  double? _distanceKm;
  AccelerometerEvent? _lastAcc;
  MagnetometerEvent? _lastMag;
  bool _isStarted = false;
  double _smoothedHeading = 0;
  bool _hasFirstReading = false;
  DateTime _lastEmitTime = DateTime(0);

  @override
  Stream<Either<Failure, QiblaData>> watchQibla() {
    _controller ??= StreamController<Either<Failure, QiblaData>>.broadcast();
    if (!_isStarted) {
      _isStarted = true;
      _start(); // intentionally unawaited, emits errors on stream
    }
    return _controller!.stream;
  }

  Future<void> _start() async {
    final failure = await _ensureLocation();
    if (failure != null) {
      _controller?.add(Left(failure));
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _qiblaBearing = calculateQiblaBearing(pos.latitude, pos.longitude);
      _distanceKm = calculateDistanceKm(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('[Qibla] position failed: $e');
      _controller?.add(const Left(LocationFailure('Unable to determine location')));
      return;
    }

    _accSub = accelerometerEventStream().listen((e) {
      _lastAcc = e;
      _tryEmit();
    });
    _magSub = magnetometerEventStream().listen((e) {
      _lastMag = e;
      _tryEmit();
    });
  }

  void _tryEmit() {
    final acc = _lastAcc;
    final mag = _lastMag;
    final bearing = _qiblaBearing;
    final distance = _distanceKm;
    if (acc == null || mag == null || bearing == null || distance == null) {
      return;
    }

    // Throttle: emit at most every 50ms (~20 Hz)
    final now = DateTime.now();
    if (now.difference(_lastEmitTime).inMilliseconds < 50) return;
    _lastEmitTime = now;

    final raw = computeHeading(
      ax: acc.x,
      ay: acc.y,
      az: acc.z,
      mx: mag.x,
      my: mag.y,
      mz: mag.z,
    );

    if (!_hasFirstReading) {
      _smoothedHeading = raw;
      _hasFirstReading = true;
    } else {
      _smoothedHeading = angleLowPass(_smoothedHeading, raw, alpha: 0.2);
    }

    _controller?.add(
      Right(
        QiblaData(
          qiblaBearing: bearing,
          deviceHeading: _smoothedHeading,
          distanceKm: distance,
        ),
      ),
    );
  }

  Future<Failure?> _ensureLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return const LocationServiceDisabledFailure();

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return const LocationPermissionFailure();
    }
    return null;
  }

  @override
  Future<void> dispose() async {
    _isStarted = false;
    _lastAcc = null;
    _lastMag = null;
    _qiblaBearing = null;
    _distanceKm = null;
    _smoothedHeading = 0;
    _hasFirstReading = false;
    _lastEmitTime = DateTime(0);
    await _accSub?.cancel();
    await _magSub?.cancel();
    await _controller?.close();
    _controller = null;
  }
}
