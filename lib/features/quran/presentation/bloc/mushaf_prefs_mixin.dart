import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mushaf_preferences.dart';
import '../../domain/entities/reading_theme.dart';
import '../../domain/i_mushaf_preferences_repository.dart';
import 'mushaf_reader_state.dart';

/// Preference setters split off from [MushafReaderCubit] to respect the
/// 150-line cap (CLAUDE.md §4) and group all persistence-touching writes
/// in one place. The concrete cubit supplies the repository via
/// [prefsRepoForMixin] so the mixin stays unaware of constructor wiring.
mixin MushafPrefsMixin on Cubit<MushafReaderState> {
  IMushafPreferencesRepository get prefsRepoForMixin;

  Future<void> setReadingTheme(ReadingTheme t) =>
      _writePrefs(state.prefs.copyWith(readingTheme: t));

  Future<void> setFontSize(double size) {
    final clamped = size.clamp(
      MushafPreferences.minFont,
      MushafPreferences.maxFont,
    );
    return _writePrefs(state.prefs.copyWith(fontSize: clamped.toDouble()));
  }

  Future<void> setContinuousPlayback(bool enabled) =>
      _writePrefs(state.prefs.copyWith(continuousPlayback: enabled));

  Future<void> setReciter(String reciterId) =>
      _writePrefs(state.prefs.copyWith(reciterId: reciterId));

  Future<void> _writePrefs(MushafPreferences next) async {
    emit(state.copyWith(prefs: next));
    await prefsRepoForMixin.save(next);
  }
}
