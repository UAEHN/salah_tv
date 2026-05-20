/// Mobile-only constants for the "Today" screen feature.
library;

/// Boundary used by `GetCurrentGreetingUseCase` to split the day into the
/// two greetings the user wants:
///   morning  : [00:00, 12:00)  → "صباح الخير"
///   evening  : [12:00, 24:00)  → "مساء الخير"
const int kEveningStartHour = 12;

/// How many days into the future the upcoming-occasion lookup considers.
/// Anything farther than this gets filtered out so the card stays relevant.
const int kUpcomingOccasionWindowDays = 60;
