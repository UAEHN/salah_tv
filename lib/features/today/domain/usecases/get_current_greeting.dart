import '../constants/today_constants.dart';
import '../entities/greeting.dart';

/// Pure synchronous use-case — picks a [Greeting] for the local hour. No
/// repository: greeting copy lives in localizations, the hour is the only
/// input. Wrapped as a use-case so the cubit doesn't reach into Dart's
/// `DateTime` directly (testable via the optional [now] override).
class GetCurrentGreetingUseCase {
  const GetCurrentGreetingUseCase();

  Greeting call({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    final period = _periodForHour(hour);
    return Greeting(
      period: period,
      titleKey: 'greeting${_capitalize(period.name)}Title',
      subtitleKey: 'greeting${_capitalize(period.name)}Subtitle',
    );
  }

  GreetingPeriod _periodForHour(int hour) => hour < kEveningStartHour
      ? GreetingPeriod.morning
      : GreetingPeriod.evening;

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
