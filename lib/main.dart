import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/app_startup.dart';
import 'features/prayer/domain/i_prayer_audio_port.dart';
import 'features/prayer/domain/i_prayer_notification_port.dart';
import 'features/prayer/domain/i_prayer_times_repository.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/prayer_event.dart';
import 'features/quran/domain/i_quran_api_repository.dart';
import 'features/settings/domain/i_settings_repository.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/app_update/presentation/bloc/update_bloc.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await initDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            getIt<ISettingsRepository>(),
            getIt<IQuranApiRepository>(),
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
        BlocProvider(
          create: (_) => getIt<UpdateBloc>(),
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

  @override
  void initState() {
    super.initState();
    _sp = context.read<SettingsProvider>();
    _sp.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    context.read<PrayerBloc>().add(PrayerSettingsUpdated(_sp.settings));
  }

  @override
  void dispose() {
    _sp.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SalahTvApp();
}
