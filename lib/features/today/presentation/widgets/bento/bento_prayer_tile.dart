import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../prayer/presentation/bloc/prayer_bloc.dart';
import 'bento_tile.dart';
import 'hero_decorations.dart';

/// Primary (Hero) tile of the bento — the "now" prayer block.
///
/// Layout (top → bottom):
///   • LIVE pill (uppercase, accent-tinted dot)
///   • Prayer name (display weight)
///   • Countdown (tabular, ~30px) — pure black on light surfaces, pure
///     white on dark surfaces (deeper contrast than `foreground`).
///   • Thin progress bar (palette accent, fills as the prayer approaches
///     within the last hour — see `_progress`)
///
/// Visually flagged as the focal point of the screen via a palette-tinted
/// gradient surface and a slightly stronger border. Both come from
/// `BentoSurface.accentTileGradient` / `accentTileBorder` so widget code
/// stays declarative (CLAUDE.md §3 — no logic in widgets).
class BentoPrayerTile extends StatelessWidget {
  const BentoPrayerTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final accentEnd = MobileColors.activePrimaryContainer(context);
    final surface = BentoSurface.of(context);
    final snapshot = context.select<PrayerBloc, _Snapshot>(
      (b) => _Snapshot(
        prayerKey: b.state.nextPrayerKey,
        countdown: b.state.countdown,
      ),
    );

    // Hero tile sits on a saturated palette gradient → all foreground
    // pixels render in white, the progress bar uses white-on-white-tint
    // so it stays legible without competing visually.
    const heroForeground = Colors.white;
    final heroSubtle = Colors.white.withValues(alpha: 0.78);

    return BentoTile(
      padding: EdgeInsets.zero,
      gradient: surface.accentTileGradient(accent, accentEnd),
      borderColor: surface.accentTileBorder(accent),
      borderWidth: surface.accentTileBorderWidth,
      boxShadow: [surface.accentTileShadow(accent)],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const HeroHighlight(),
            HeroNoise(isDark: surface.isDarkSky),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LivePill(label: l.todayPrayerStartsIn, color: heroSubtle),
                  const Spacer(),
                  Text(
                    localizedPrayerName(context, snapshot.prayerKey),
                    style: MobileTextStyles.titleMd(context).copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: heroForeground,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _formatCountdown(snapshot.countdown),
                      style: TextStyle(
                        fontFamily:
                            Theme.of(context).textTheme.bodyMedium?.fontFamily,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: heroForeground,
                        letterSpacing: 0.6,
                        height: 1.0,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ProgressBar(progress: _progress(snapshot.countdown)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(Duration d) {
    final neg = d.isNegative;
    final abs = d.abs();
    final h = abs.inHours.toString().padLeft(2, '0');
    final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final s = (abs.inSeconds % 60).toString().padLeft(2, '0');
    return neg ? '-$h:$m:$s' : '$h:$m:$s';
  }

  double _progress(Duration countdown) {
    if (countdown.isNegative) return 1.0;
    const oneHour = Duration(hours: 1);
    if (countdown >= oneHour) return 0.05;
    return 1.0 - (countdown.inSeconds.clamp(0, 3600) / 3600.0);
  }
}

class _LivePill extends StatelessWidget {
  final String label;
  final Color color;

  const _LivePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: MobileTextStyles.labelSm(context).copyWith(
            color: color,
            fontSize: 11,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(
            height: 5,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Snapshot {
  final String prayerKey;
  final Duration countdown;

  const _Snapshot({required this.prayerKey, required this.countdown});

  @override
  bool operator ==(Object other) =>
      other is _Snapshot &&
      other.prayerKey == prayerKey &&
      other.countdown.inSeconds == countdown.inSeconds;

  @override
  int get hashCode => Object.hash(prayerKey, countdown.inSeconds);
}
