import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_switch_row.dart';

class MakkahStreamSection extends StatelessWidget {
  const MakkahStreamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TvSwitchRow(
          value: settings.isMakkahStreamEnabled,
          accent: palette.primary,
          onChanged: settingsProv.updateMakkahStreamEnabled,
          children: [
            Icon(
              Icons.videocam_rounded,
              color: settings.isMakkahStreamEnabled
                  ? palette.primary
                  : tc.textMuted,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              'بث مكة المكرمة المباشر:',
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.isMakkahStreamEnabled,
              activeTrackColor: palette.primary,
              inactiveTrackColor: tc.textMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: settingsProv.updateMakkahStreamEnabled,
            ),
            const SizedBox(width: 12),
            Text(
              settings.isMakkahStreamEnabled ? 'مفعّل' : 'معطّل',
              style: TextStyle(
                fontSize: 20,
                color: settings.isMakkahStreamEnabled
                    ? palette.primary
                    : tc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (settings.isMakkahStreamEnabled) ...[
          const SizedBox(height: 12),
          TvSwitchRow(
            value: settings.isMakkahStreamAudioEnabled,
            accent: palette.primary,
            onChanged: settingsProv.updateMakkahStreamAudio,
            children: [
              Icon(
                settings.isMakkahStreamAudioEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: settings.isMakkahStreamAudioEnabled
                    ? palette.primary
                    : tc.textMuted,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  settings.isMakkahStreamAudioEnabled
                      ? 'صوت البث المباشر (يوقف القرآن)'
                      : 'فيديو صامت — يستمر القرآن',
                  style: TextStyle(fontSize: 18, color: tc.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: settings.isMakkahStreamAudioEnabled,
                activeTrackColor: palette.primary,
                inactiveTrackColor: tc.textMuted.withValues(alpha: 0.3),
                thumbColor: WidgetStateProperty.all(Colors.white),
                onChanged: settingsProv.updateMakkahStreamAudio,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: tc.glass(opacity: 0.05, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.wifi_rounded, color: tc.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يتطلب اتصالاً بالإنترنت • التخطيط الحديث فقط',
                    style: TextStyle(fontSize: 14, color: tc.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
