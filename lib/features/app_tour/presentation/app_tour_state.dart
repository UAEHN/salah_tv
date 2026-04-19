enum AppTourStatus { initial, requested, completed }

class AppTourState {
  final AppTourStatus status;

  const AppTourState({this.status = AppTourStatus.initial});

  AppTourState copyWith({AppTourStatus? status}) =>
      AppTourState(status: status ?? this.status);
}
