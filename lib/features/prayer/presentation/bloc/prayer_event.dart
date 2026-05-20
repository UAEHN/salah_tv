import '../../../settings/domain/entities/app_settings.dart';

abstract class PrayerEvent {
  const PrayerEvent();
}

class PrayerStarted extends PrayerEvent {
  const PrayerStarted();
}

class PrayerResumed extends PrayerEvent {
  const PrayerResumed();
}

class PrayerPaused extends PrayerEvent {
  const PrayerPaused();
}

class PrayerSettingsUpdated extends PrayerEvent {
  final AppSettings settings;
  const PrayerSettingsUpdated(this.settings);
}

class PrayerAdhanStopped extends PrayerEvent {
  const PrayerAdhanStopped();
}

class PrayerDuaStopped extends PrayerEvent {
  const PrayerDuaStopped();
}

class PrayerIqamaStopped extends PrayerEvent {
  const PrayerIqamaStopped();
}

class PrayerQuranToggled extends PrayerEvent {
  final String? serverUrl;
  const PrayerQuranToggled(this.serverUrl);
}

/// Toggles the Eid Takbeerat background track. Empty/null [url] is a no-op
/// when starting (nothing to play); when stopping the engine ignores it
/// and tears down whatever is loaded.
class PrayerTakbeeratToggled extends PrayerEvent {
  final String url;
  const PrayerTakbeeratToggled(this.url);
}

/// Full stop: clears surah/cursor/counts so the next start begins from the
/// position dictated by the current playback mode (playlist[0], selected
/// surah, or continuous start mode).
class PrayerQuranStopped extends PrayerEvent {
  const PrayerQuranStopped();
}

class PrayerReloaded extends PrayerEvent {
  const PrayerReloaded();
}

class PrayerDateChanged extends PrayerEvent {
  final int dayOffset;
  const PrayerDateChanged(this.dayOffset);
}

class PrayerDateReset extends PrayerEvent {
  const PrayerDateReset();
}

/// Internal: dispatched by the engine's notify callback on every tick.
/// Do not dispatch externally.
class PrayerEngineRefreshed extends PrayerEvent {
  const PrayerEngineRefreshed();
}
