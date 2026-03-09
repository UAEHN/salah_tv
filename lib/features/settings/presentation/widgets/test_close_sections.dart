import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../prayer/presentation/prayer_provider.dart';
import '../settings_provider.dart';
import 'tv_button.dart';

class TestSection extends StatelessWidget {
  const TestSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = getThemePalette(
        context.watch<SettingsProvider>().settings.themeColorKey);
    return Row(
      children: [
        TvButton(
          onPressed: () {
            context.read<PrayerProvider>().testAdhan();
            Navigator.pop(context);
          },
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('اختبار الأذان', style: TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        TvButton(
          onPressed: () {
            context.read<PrayerProvider>().testIqama();
            Navigator.pop(context);
          },
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('اختبار الإقامة', style: TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class CloseAppSection extends StatelessWidget {
  const CloseAppSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TvButton(
      onPressed: () => SystemNavigator.pop(),
      accent: const Color(0xFFEF4444),
      filled: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('إغلاق التطبيق', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}
