import '../../domain/entities/khatma_plan.dart';

/// Immutable snapshot of the active Khatma.
class KhatmaState {
  final bool isLoaded;
  final Khatma? khatma;

  const KhatmaState({this.isLoaded = false, this.khatma});

  bool get hasActive => khatma != null && khatma!.status == KhatmaStatus.active;

  bool get isCompleted =>
      khatma != null && khatma!.status == KhatmaStatus.completed;
}
