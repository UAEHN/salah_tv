import 'entities/mushaf_preferences.dart';

/// Persistence port for the Mushaf reader's local preferences (theme,
/// font size, continuous-playback toggle).
abstract class IMushafPreferencesRepository {
  Future<MushafPreferences> load();
  Future<void> save(MushafPreferences prefs);
}
