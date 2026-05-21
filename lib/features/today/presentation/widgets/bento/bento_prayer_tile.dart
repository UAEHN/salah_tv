import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/boxed_countdown.dart';
import '../../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../../prayer/presentation/bloc/prayer_state.dart';
import 'bento_tile.dart';
import 'hero_decorations.dart';

/// Primary (Hero) tile of the bento — the "now" prayer block.
///
/// Two visual modes:
///   • Compact (default) — original design used when the occasion sibling
///     is present. LIVE pill → name → countdown → progress bar.
///   • Expanded — full-row variant rendered when no occasion is available.
///     Larger type, no pill, segmented digit-box countdown.
class BentoPrayerTile extends StatelessWidget {
  /// `true` → tile fills the row alone (no occasion sibling). Triggers the
  /// larger expanded layout; otherwise the original compact layout renders.
  final bool isExpanded;

  const BentoPrayerTile({super.key, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final accentEnd = MobileColors.activePrimaryContainer(context);
    final surface = BentoSurface.of(context);
    final snapshot = context.select<PrayerBloc, _Snapshot>(
      (b) => _Snapshot.from(b.state),
    );

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
            isExpanded
                ? _ExpandedBody(snapshot: snapshot)
                : _CompactBody(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

/// Original layout: pill → spacer → name → countdown → progress bar.
class _CompactBody extends StatelessWidget {
  final _Snapshot snapshot;
  const _CompactBody({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    const heroForeground = Colors.white;
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (snapshot.isIqama) ...[
            _IqamaBadge(label: l.iqamaLabel),
            const SizedBox(height: 6),
          ],
          Text(
            localizedPrayerName(context, snapshot.prayerKey),
            style: MobileTextStyles.titleMd(context).copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: heroForeground,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _formatCountdown(snapshot.countdown),
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: heroForeground,
                letterSpacing: 0.6,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ProgressBar(progress: _progress(snapshot.countdown)),
        ],
      ),
    );
  }
}

/// Full-row variant: bigger name, segmented digit-box countdown filling
/// the width, content vertically centered with no pill.
class _ExpandedBody extends StatelessWidget {
  final _Snapshot snapshot;
  const _ExpandedBody({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    const heroForeground = Colors.white;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (snapshot.isIqama) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: _IqamaBadge(label: AppLocalizations.of(context).iqamaLabel),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 2),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                localizedPrayerName(context, snapshot.prayerKey),
                style: MobileTextStyles.titleMd(context).copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: heroForeground,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.fitWidth,
            alignment: AlignmentDirectional.centerStart,
            child: BoxedCountdown(
              countdown: snapshot.countdown,
              foreground: heroForeground,
              fontSize: 56,
              dropHoursWhenZero: false,
            ),
          ),
          const SizedBox(height: 14),
          _ProgressBar(progress: _progress(snapshot.countdown)),
        ],
      ),
    );
  }
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

/// Small white-on-accent pill shown above the prayer name during an
/// active iqama countdown so the user knows the countdown they see is for
/// the iqama (الإقامة) and not the next adhan.
class _IqamaBadge extends StatelessWidget {
  final String label;
  const _IqamaBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          height: 1.0,
        ),
      ),
    );
  }
}

// _BoxedCountdown moved to lib/core/widgets/mobile/boxed_countdown.dart so
// the same visual is reused on the prayer-times screen hero card.

/// What the hero tile should display, derived from the prayer state.
/// During an active iqama countdown the iqama timing + prayer key win;
/// otherwise the next-prayer countdown is used. The `isIqama` flag drives
/// the small "الإقامة" label above the prayer name.
class _Snapshot {
  final String prayerKey;
  final Duration countdown;
  final bool isIqama;

  const _Snapshot({
    required this.prayerKey,
    required this.countdown,
    required this.isIqama,
  });

  factory _Snapshot.from(PrayerState state) {
    if (state.isIqamaCountdown) {
      return _Snapshot(
        prayerKey: state.iqamaPrayerKey,
        countdown: state.iqamaCountdown,
        isIqama: true,
      );
    }
    return _Snapshot(
      prayerKey: state.nextPrayerKey,
      countdown: state.countdown,
      isIqama: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _Snapshot &&
      other.prayerKey == prayerKey &&
      other.countdown.inSeconds == countdown.inSeconds &&
      other.isIqama == isIqama;

  @override
  int get hashCode =>
      Object.hash(prayerKey, countdown.inSeconds, isIqama);
}
