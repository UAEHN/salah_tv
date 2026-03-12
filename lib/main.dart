import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';
import 'models/app_settings.dart';
import 'features/audio/data/audio_service.dart';
import 'features/prayer/data/sqlite_prayer_repository.dart';
import 'features/quran/data/quran_api_service.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/prayer/presentation/prayer_provider.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/app_update/presentation/bloc/update_bloc.dart';
import 'features/app_update/presentation/bloc/update_event.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  // Keep screen on permanently — TV display app
  await WakelockPlus.enable();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final repo = SettingsRepository();
  final AppSettings settings = await repo.load();

  final csvService = SqlitePrayerRepository();
  await csvService.initialize(settings.selectedCountry);

  final audioService = AudioService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsProvider(repo, csvService, QuranApiService(), settings),
        ),
        // ChangeNotifierProxyProvider ensures PrayerProvider always receives
        // the latest AppSettings whenever the user changes any setting.
        ChangeNotifierProxyProvider<SettingsProvider, PrayerProvider>(
          create: (_) =>
              PrayerProvider(csvService, audioService, settings)..start(),
          update: (_, settingsProv, prayerProv) {
            prayerProv!.updateSettings(settingsProv.settings);
            return prayerProv;
          },
        ),
        BlocProvider(
          create: (_) => getIt<UpdateBloc>()..add(CheckForUpdateEvent()),
        ),
      ],
      child: const SalahTvApp(),
    ),
  );
}
