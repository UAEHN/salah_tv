import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../../../adhkar/domain/entities/adhkar_session.dart';
import '../../../adhkar/domain/i_adhkar_audio_port.dart';
import '../../../adhkar/domain/i_adhkar_state_repository.dart';
import '../../../adhkar/presentation/bloc/adhkar_hero_cubit.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import 'adhkar_countdown_badge.dart';

class AdhkarHeroContent extends StatefulWidget {
  final AdhkarSession session;

  const AdhkarHeroContent({required this.session, super.key});

  @override
  State<AdhkarHeroContent> createState() => _AdhkarHeroContentState();
}

class _AdhkarHeroContentState extends State<AdhkarHeroContent> {
  late final AdhkarHeroCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AdhkarHeroCubit(
      context.read<IAdhkarAudioPort>(),
      context.read<IAdhkarStateRepository>(),
    )..start(widget.session);
  }

  @override
  void didUpdateWidget(AdhkarHeroContent old) {
    super.didUpdateWidget(old);
    if (old.session != widget.session) _cubit.switchSession(widget.session);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prayerState = context.watch<PrayerBloc>().state;
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;
    final sessionLabel = widget.session == AdhkarSession.morning
        ? l.adhkarMorningSession
        : l.adhkarEveningSession;

    return BlocBuilder<AdhkarHeroCubit, AdhkarHeroState>(
      bloc: _cubit,
      builder: (context, state) {
        final dhikr = state.currentDhikr;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdhkarCountdownBadge(
              sessionLabel: sessionLabel,
              prayerName: localizedPrayerName(context, prayerState.nextPrayerKey),
              countdown: formatCountdown(prayerState.countdown),
              screenH: screenH,
              tc: tc,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Center(
                  key: ValueKey(state.index),
                  child: Text(
                    dhikr?.text ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenH * 0.040,
                      fontWeight: FontWeight.w500,
                      color: tc.textPrimary,
                      height: 1.9,
                    ),
                  ),
                ),
              ),
            ),
            if (dhikr != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '${state.index + 1} / ${state.adhkar.length}',
                  style: TextStyle(
                    fontSize: screenH * 0.020,
                    color: tc.textMuted,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
