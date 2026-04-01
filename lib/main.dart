import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/app_startup.dart';
import 'features/adhkar/domain/i_adhkar_audio_port.dart';
import 'features/adhkar/domain/i_adhkar_state_repository.dart';
import 'features/prayer/domain/i_prayer_audio_port.dart';
import 'features/notifications/domain/i_prayer_notification_port.dart';
import 'features/prayer/domain/i_prayer_times_repository.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/prayer_event.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/domain/entities/app_settings_copy_with.dart';
import 'features/settings/domain/i_location_detector.dart';
import 'features/settings/domain/i_settings_repository.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await initDependencies();
  runApp(
    MultiProvider(
      providers: [
        Provider<IAdhkarAudioPort>.value(
          value: getIt<IAdhkarAudioPort>(),
        ),
        Provider<IAdhkarStateRepository>.value(
          value: getIt<IAdhkarStateRepository>(),
        ),
        Provider<ISettingsRepository>.value(
          value: getIt<ISettingsRepository>(),
        ),
        if (getIt.isRegistered<ILocationDetector>())
          Provider<ILocationDetector>.value(
            value: getIt<ILocationDetector>(),
          ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            getIt<ISettingsRepository>(),
            settings,
          ),
        ),
        BlocProvider(
          create: (_) => PrayerBloc(
            getIt<IPrayerTimesRepository>(),
            getIt<IPrayerAudioPort>(),
            settings,
            notifications: getIt.isRegistered<IPrayerNotificationPort>()
                ? getIt<IPrayerNotificationPort>()
                : null,
          )..add(const PrayerStarted()),
        ),
      ],
      child: const _SettingsBridgeWrapper(),
    ),
  );
}

/// Bridges [SettingsProvider] → [PrayerBloc]: listens for settings changes and
/// dispatches [PrayerSettingsUpdated] only when settings actually change,
/// never on unrelated widget rebuilds.
class _SettingsBridgeWrapper extends StatefulWidget {
  const _SettingsBridgeWrapper();

  @override
  State<_SettingsBridgeWrapper> createState() => _SettingsBridgeWrapperState();
}

class _SettingsBridgeWrapperState extends State<_SettingsBridgeWrapper> {
  late final SettingsProvider _sp;
  late AppSettings _prev;

  @override
  void initState() {
    super.initState();
    _sp = context.read<SettingsProvider>();
    _prev = _sp.settings;
    _sp.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    final next = _sp.settings;
    if (_prev.prayerFieldsEqual(next)) { _prev = next; return; }
    _prev = next;
    context.read<PrayerBloc>().add(PrayerSettingsUpdated(next));
  }

  @override
  void dispose() {
    _sp.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const GhasaqApp();
}
