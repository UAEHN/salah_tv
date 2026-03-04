import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';
import 'models/app_settings.dart';
import 'services/audio_service.dart';
import 'services/csv_service.dart';
import 'services/settings_repository.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep screen on permanently — TV display app
  await WakelockPlus.enable();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final repo = SettingsRepository();
  final AppSettings settings = await repo.load();

  final csvService = CsvService();
  await csvService.initialize(settings.csvFilePath);

  final audioService = AudioService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(repo, settings),
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
      ],
      child: const SalahTvApp(),
    ),
  );
}
