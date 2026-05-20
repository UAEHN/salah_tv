import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';
import '../../../../adhkar/domain/entities/adhkar_session.dart';
import '../../../../prayer/presentation/bloc/prayer_bloc.dart';
import 'bento_tile.dart';

/// Suggests the dhikr session that fits the current local time.
///
/// Boundaries (the user's spec):
///   • before Asr            → morning  (أذكار الصباح)
///   • Asr → 22:00           → evening  (أذكار المساء)
///   • 22:00 → 04:00         → sleep    (أذكار النوم)
///
/// `Asr` is read from `PrayerBloc.state.todayPrayers` so it reflects the
/// real local time. If the prayer state hasn't loaded yet a 15:00 fallback
/// is used so the tile never gets stuck on "morning" all afternoon.
class BentoTimeDhikrTile extends StatelessWidget {
  const BentoTimeDhikrTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final surface = BentoSurface.of(context);
    final preset = context.select<PrayerBloc, _Preset>(
      (b) => _presetFor(b.state.now, b.state.todayPrayers?.asr),
    );
    final title = _titleFor(l, preset);

    return BentoTile(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(preset.icon, size: 22, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.todayDhikrEyebrow.toUpperCase(),
                  style: MobileTextStyles.labelSm(context).copyWith(
                    fontSize: 11,
                    letterSpacing: 1.8,
                    color: surface.foregroundMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: MobileTextStyles.headlineMd(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: surface.foreground,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StartButton(
            label: l.todayDhikrStart,
            onTap: () => MobileShell.openAdhkarSession(context, preset.session),
          ),
        ],
      ),
    );
  }

  _Preset _presetFor(DateTime now, DateTime? asr) {
    // Sleep is a hard window — 22:00 → 04:00 — regardless of prayer times,
    // so the tile always lands on sleep at night even before today's
    // prayer state finishes loading.
    if (now.hour >= 22 || now.hour < 4) {
      return const _Preset(
        session: AdhkarSession.evening,
        icon: Icons.nightlight_round,
        kind: _PresetKind.sleep,
      );
    }
    // Evening adhkar kick in right after Asr. Fallback to a 15:00 boundary
    // when prayer times haven't loaded yet so the user doesn't see the
    // morning suggestion at 7pm.
    final asrTime = asr ?? DateTime(now.year, now.month, now.day, 15);
    if (!now.isBefore(asrTime)) {
      return const _Preset(
        session: AdhkarSession.evening,
        icon: Icons.wb_twilight_rounded,
        kind: _PresetKind.evening,
      );
    }
    return const _Preset(
      session: AdhkarSession.morning,
      icon: Icons.wb_sunny_rounded,
      kind: _PresetKind.morning,
    );
  }

  String _titleFor(AppLocalizations l, _Preset p) {
    switch (p.kind) {
      case _PresetKind.morning:
        return l.todayDhikrTitleMorning;
      case _PresetKind.evening:
        return l.todayDhikrTitleEvening;
      case _PresetKind.sleep:
        return l.todayDhikrTitleSleep;
    }
  }
}

enum _PresetKind { morning, evening, sleep }

class _Preset {
  final AdhkarSession session;
  final IconData icon;
  final _PresetKind kind;
  const _Preset({
    required this.session,
    required this.icon,
    required this.kind,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _Preset &&
          other.session == session &&
          other.icon == icon &&
          other.kind == kind);

  @override
  int get hashCode => Object.hash(session, icon, kind);
}

class _StartButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StartButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: MobileTextStyles.labelSm(context).copyWith(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
