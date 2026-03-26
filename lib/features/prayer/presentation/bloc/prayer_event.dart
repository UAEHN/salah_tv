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
