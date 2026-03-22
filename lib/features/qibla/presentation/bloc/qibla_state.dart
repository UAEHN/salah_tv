import '../../domain/entities/qibla_data.dart';

sealed class QiblaState {}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaPermissionDenied extends QiblaState {}

class QiblaLocationDisabled extends QiblaState {}

class QiblaError extends QiblaState {
  final String message;
  QiblaError(this.message);
}

class QiblaActive extends QiblaState {
  final QiblaData data;
  QiblaActive(this.data);
}
