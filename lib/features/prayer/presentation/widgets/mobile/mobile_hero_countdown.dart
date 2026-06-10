import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';
import '../../../../../core/widgets/mobile/boxed_countdown.dart';
import 'mobile_hero_parts.dart';
import 'mobile_prayer_visuals.dart';

/// Hero countdown section — gradient card with circular arc and countdown.
class MobileHeroCountdown extends StatelessWidget {
  final String nextPrayerKey;
  final Duration countdown;
  final bool isCycleActive;
  final bool isIqamaCountdown;
  final Duration iqamaCountdown;
  final String iqamaPrayerKey;
  final double progress;

  const MobileHeroCountdown({
    super.key,
    required this.nextPrayerKey,
    required this.countdown,
    required this.isCycleActive,
    required this.isIqamaCountdown,
    required this.iqamaCountdown,
    required this.iqamaPrayerKey,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = MobileColors.isDark(context);
    final prayerKey = isIqamaCountdown ? iqamaPrayerKey : nextPrayerKey;
    final colors = mobilePrayerAccentPair(context, prayerKey);
    final accentBright = colors.$1;
    final accentDeep = colors.$2;
    final icon = mobilePrayerIcons[prayerKey] ?? Icons.access_time_rounded;

    final nextPrayerName = localizedPrayerName(context, nextPrayerKey);
    final iqamaPrayerName = localizedPrayerName(context, iqamaPrayerKey);

    final subtitle = isIqamaCountdown
        ? l.countdownToIqama(iqamaPrayerName)
        : isCycleActive
        ? l.ongoingNow
        : l.countdownNextPrayer(nextPrayerName);

    final countdownDuration = isIqamaCountdown ? iqamaCountdown : countdown;
    final displayText = isCycleActive && !isIqamaCountdown
        ? iqamaPrayerName
        : formatCountdown(countdownDuration);

    final isCountdownMode = !isCycleActive || isIqamaCountdown;
    // Digits stay black/white for max contrast; the surrounding boxes
    // pick up the active accent so the countdown harmonises with the
    // rest of the hero card without compromising legibility.
    final foreground = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: _heroDecoration(isDark, accentBright, accentDeep),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial glow — top right
          Positioned(
            top: -30,
            right: -20,
            child: HeroGlowOrb(
              size: 120,
              color: accentBright.withValues(alpha: isDark ? 0.15 : 0.12),
            ),
          ),
          // Radial glow — bottom left
          Positioned(
            bottom: -35,
            left: -15,
            child: HeroGlowOrb(
              size: 100,
              color: accentDeep.withValues(alpha: isDark ? 0.12 : 0.08),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arc ring with icon
                HeroArcWithIcon(
                  icon: icon,
                  progress: progress,
                  accentBright: accentBright,
                  accentDeep: accentDeep,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                // Countdown — boxed segmented clock when counting down,
                // plain title text during an active cycle (iqama prayer
                // name shown instead of digits).
                isCountdownMode
                    ? BoxedCountdown(
                        countdown: countdownDuration,
                        foreground: foreground,
                        boxTint: accentDeep,
                        fontSize: 36,
                      )
                    : Text(
                        displayText,
                        style: MobileTextStyles.displayLg(context).copyWith(
                          fontSize: 34,
                          color: foreground,
                          shadows: [
                            BoxShadow(
                              color: accentBright.withValues(alpha: 0.4),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 6),
                // Subtitle pill
                HeroSubtitlePill(
                  text: subtitle,
                  isDark: isDark,
                  accentColor: accentBright,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _heroDecoration(bool isDark, Color bright, Color deep) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Color.alphaBlend(
                  deep.withValues(alpha: 0.15),
                  const Color(0xFF151C2C),
                ),
                const Color(0xFF0C1322),
                const Color(0xFF080C16),
              ]
            : [
                Color.alphaBlend(
                  bright.withValues(alpha: 0.12),
                  const Color(0xFFFFFDF8),
                ),
                Color.alphaBlend(
                  bright.withValues(alpha: 0.05),
                  const Color(0xFFF9F6F0),
                ),
                const Color(0xFFF5EEDB),
              ],
      ),
      boxShadow: [
        BoxShadow(
          color: deep.withValues(alpha: isDark ? 0.3 : 0.15),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ],
    );
  }
}
