import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';

class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      width: screenW,
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.03,
        vertical: screenH * 0.015,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.primary.withValues(alpha: 0.2),
            palette.secondary.withValues(alpha: 0.12),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Test Adhan Button
          Focus(
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.select ||
                      event.logicalKey == LogicalKeyboardKey.enter)) {
                context.read<PrayerProvider>().testAdhan();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: () => context.read<PrayerProvider>().testAdhan(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenH * 0.015,
                  vertical: screenH * 0.006,
                ),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded,
                        color: palette.primary, size: screenH * 0.022),
                    SizedBox(width: screenW * 0.005),
                    Text(
                      'تجربة الأذان',
                      style: TextStyle(
                        fontSize: screenH * 0.022,
                        color: palette.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: screenW * 0.015),
          // Settings Hint
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenH * 0.015,
              vertical: screenH * 0.006,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_remote,
                    color: kTextMuted, size: screenH * 0.022),
                SizedBox(width: screenW * 0.005),
                Text(
                  'اضغط OK للإعدادات',
                  style: TextStyle(
                    fontSize: screenH * 0.022,
                    color: kTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
