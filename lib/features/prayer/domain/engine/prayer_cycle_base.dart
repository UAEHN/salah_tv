import '../i_prayer_audio_port.dart';
import '../i_prayer_times_repository.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'prayer_cycle_state.dart';

/// Abstract base that all [PrayerCycleEngine] mixins constrain on.
/// Exposes the shared state container and injected dependencies so every
/// mixin can operate on them without coupling to the concrete engine class.
abstract class PrayerCycleBase {
  PrayerCycleState get s;
  IPrayerAudioPort get audio;
  IPrayerTimesRepository get repo;
  AppSettings get settings;
  set settings(AppSettings value);
  void Function() get notify;
}
