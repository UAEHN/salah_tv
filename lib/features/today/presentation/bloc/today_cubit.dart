import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/daily_verse.dart';
import '../../domain/entities/upcoming_occasion.dart';
import '../../domain/usecases/get_current_greeting.dart';
import '../../domain/usecases/get_daily_verse.dart';
import '../../domain/usecases/get_upcoming_occasion.dart';
import 'today_state.dart';

/// Loads the dynamic content for the Today hub. Static cards (next prayer,
/// hijri date) are driven by their own existing blocs/widgets — this cubit
/// only owns the data that the screen itself fetches.
class TodayCubit extends Cubit<TodayState> {
  final GetCurrentGreetingUseCase _getGreeting;
  final GetUpcomingOccasionUseCase _getOccasion;
  final GetDailyVerseUseCase _getVerse;

  TodayCubit({
    required GetCurrentGreetingUseCase getGreeting,
    required GetUpcomingOccasionUseCase getOccasion,
    required GetDailyVerseUseCase getVerse,
  }) : _getGreeting = getGreeting,
       _getOccasion = getOccasion,
       _getVerse = getVerse,
       super(const TodayLoading());

  Future<void> load({DateTime? now}) async {
    final greeting = _getGreeting(now: now);

    final occasionResult = await _getOccasion(now: now);
    final verseResult = await _getVerse(now: now);

    UpcomingOccasion? occasion;
    DailyVerse? verse;
    var partial = false;

    occasionResult.fold((_) => partial = true, (value) => occasion = value);
    verseResult.fold((_) => partial = true, (value) => verse = value);

    emit(
      TodayLoaded(
        greeting: greeting,
        upcomingOccasion: occasion,
        dailyVerse: verse,
        hasPartialFailure: partial,
      ),
    );
  }

  /// Re-evaluate the greeting only — cheap, used by the screen on resume so
  /// the title flips when the user crosses a period boundary while the app
  /// was in the background.
  void refreshGreeting({DateTime? now}) {
    final s = state;
    if (s is! TodayLoaded) return;
    final greeting = _getGreeting(now: now);
    if (greeting == s.greeting) return;
    emit(s.copyWith(greeting: greeting));
  }
}
