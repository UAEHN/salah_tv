import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/adhan_sounds.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/adhan_sound_localizer.dart';
import '../../../../injection.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/prayer_sound_mode.dart';
import '../../domain/usecases/delete_custom_adhan_usecase.dart';
import '../../domain/usecases/import_custom_adhan_usecase.dart';
import '../bloc/custom_adhan_cubit.dart';
import '../settings_provider.dart';
import 'section_title.dart';
import 'sound_mode_picker.dart';
import 'sound_picker_row.dart';

class AdhanSection extends StatelessWidget {
  const AdhanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final adhanHasSound = settings.adhanMode == PrayerSoundMode.sound;
    final iqamaHasSound = settings.iqamaMode == PrayerSoundMode.sound;

    return BlocProvider<CustomAdhanCubit>(
      create: (_) => CustomAdhanCubit(
        import: getIt<ImportCustomAdhanUseCase>(),
        delete: getIt<DeleteCustomAdhanUseCase>(),
        settings: context.read<SettingsProvider>(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (adhanHasSound) ...[
            SettingsSectionTitle(title: l.settingsAdhanSoundLabel),
            const SizedBox(height: 12),
            SoundPickerRow(
              palette: palette,
              tc: tc,
              isIqama: false,
              changeLabel: l.settingsChangeAdhan,
              currentLabel: _adhanLabel(context, settings),
            ),
            const SizedBox(height: 24),
          ],
          SettingsSectionTitle(title: l.adhanLabel),
          const SizedBox(height: 12),
          SoundModePicker(
            value: settings.adhanMode,
            onChanged: settingsProv.updateAdhanMode,
            palette: palette,
            tc: tc,
          ),
          const SizedBox(height: 24),
          if (iqamaHasSound) ...[
            SettingsSectionTitle(title: l.settingsIqamaSoundLabel),
            const SizedBox(height: 12),
            SoundPickerRow(
              palette: palette,
              tc: tc,
              isIqama: true,
              changeLabel: l.settingsChangeIqama,
              currentLabel: _iqamaLabel(context, settings),
            ),
            const SizedBox(height: 24),
          ],
          SettingsSectionTitle(title: l.iqamaLabel),
          const SizedBox(height: 12),
          SoundModePicker(
            value: settings.iqamaMode,
            onChanged: settingsProv.updateIqamaMode,
            palette: palette,
            tc: tc,
          ),
        ],
      ),
    );
  }

  String _adhanLabel(BuildContext context, AppSettings settings) {
    return soundDisplayLabel(
      settings.adhanSound,
      settings.customAdhans.map<({String key, String label})>(
        (c) => (key: c.settingsKey, label: c.label),
      ),
      localizedAdhanSoundLabel(
        context,
        kAdhanSounds
            .firstWhere(
              (s) => s.key == settings.adhanSound,
              orElse: () => kAdhanSounds.first,
            )
            .key,
      ),
    );
  }

  String _iqamaLabel(BuildContext context, AppSettings settings) {
    final l = AppLocalizations.of(context);
    return soundDisplayLabel(
      settings.iqamaSound,
      settings.customIqamas.map<({String key, String label})>(
        (c) => (key: c.settingsKey, label: c.label),
      ),
      l.iqamaDefaultSound,
    );
  }
}
