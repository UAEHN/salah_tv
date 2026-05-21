/// Persistence port for the "has the user seen the Mushaf intro?" flag.
///
/// Kept as a tiny domain interface so the reader screen can ask
/// "should I show the intro?" without depending on SharedPreferences directly.
abstract class IQuranIntroFlagRepository {
  Future<bool> hasSeenIntro();
  Future<void> markIntroSeen();
}
