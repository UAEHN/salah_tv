import '../../domain/entities/daily_verse.dart';
import '../../domain/entities/greeting.dart';
import '../../domain/entities/upcoming_occasion.dart';

sealed class TodayState {
  const TodayState();
}

class TodayLoading extends TodayState {
  const TodayLoading();

  @override
  bool operator ==(Object other) => other is TodayLoading;

  @override
  int get hashCode => 0;
}

class TodayLoaded extends TodayState {
  final Greeting greeting;
  final UpcomingOccasion? upcomingOccasion;
  final DailyVerse? dailyVerse;

  /// True if any non-greeting card failed to load. The screen still renders
  /// (partial state, CLAUDE.md §13.7 graceful degradation) — failed cards
  /// just hide themselves silently.
  final bool hasPartialFailure;

  const TodayLoaded({
    required this.greeting,
    this.upcomingOccasion,
    this.dailyVerse,
    this.hasPartialFailure = false,
  });

  TodayLoaded copyWith({
    Greeting? greeting,
    UpcomingOccasion? upcomingOccasion,
    DailyVerse? dailyVerse,
    bool? hasPartialFailure,
  }) {
    return TodayLoaded(
      greeting: greeting ?? this.greeting,
      upcomingOccasion: upcomingOccasion ?? this.upcomingOccasion,
      dailyVerse: dailyVerse ?? this.dailyVerse,
      hasPartialFailure: hasPartialFailure ?? this.hasPartialFailure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayLoaded &&
          other.greeting == greeting &&
          other.upcomingOccasion == upcomingOccasion &&
          other.dailyVerse == dailyVerse &&
          other.hasPartialFailure == hasPartialFailure;

  @override
  int get hashCode => Object.hash(
        greeting,
        upcomingOccasion,
        dailyVerse,
        hasPartialFailure,
      );
}
