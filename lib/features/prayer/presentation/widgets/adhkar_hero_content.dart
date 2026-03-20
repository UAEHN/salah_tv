import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/time_formatters.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../adhkar/domain/entities/adhkar_session.dart';
import '../../../adhkar/domain/entities/dhikr.dart';
import '../../../adhkar/domain/i_adhkar_audio_port.dart';
import '../../../adhkar/domain/i_adhkar_state_repository.dart';
import 'adhkar_countdown_badge.dart';

class AdhkarHeroContent extends StatefulWidget {
  final AdhkarSession session;

  const AdhkarHeroContent({required this.session, super.key});

  @override
  State<AdhkarHeroContent> createState() => _AdhkarHeroContentState();
}

class _AdhkarHeroContentState extends State<AdhkarHeroContent> {
  int _index = 0;
  List<Dhikr> _adhkar = const [];
  late final IAdhkarAudioPort _audio;
  StreamSubscription<void>? _completeSub;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _audio = GetIt.I<IAdhkarAudioPort>();
    _adhkar = GetIt.I<IAdhkarStateRepository>().forSession(widget.session);
    _completeSub = _audio.onComplete.listen((_) => _advance());
    final repo = GetIt.I<IAdhkarStateRepository>();
    if (widget.session == AdhkarSession.morning) {
      repo.startMorningSession();
    } else if (widget.session == AdhkarSession.evening) {
      repo.startEveningSession();
    }
    _playOrTimer();
  }

  @override
  void didUpdateWidget(AdhkarHeroContent old) {
    super.didUpdateWidget(old);
    if (old.session != widget.session) {
      _fallbackTimer?.cancel();
      _audio.stop();
      _adhkar = GetIt.I<IAdhkarStateRepository>().forSession(widget.session);
      _index = 0;
      _playOrTimer();
    }
  }

  void _endSession() {
    final repo = GetIt.I<IAdhkarStateRepository>();
    if (widget.session == AdhkarSession.morning) {
      repo.endMorningSession();
    } else if (widget.session == AdhkarSession.evening) {
      repo.endEveningSession();
    }
  }

  void _advance() {
    if (!mounted) return;
    final next = _index + 1;
    if (next >= _adhkar.length) {
      // All adhkar done — end the session so HeroCard hides this widget.
      _fallbackTimer?.cancel();
      _endSession();
      return;
    }
    setState(() => _index = next);
    _playOrTimer();
  }

  /// Plays audio for current dhikr if available and Quran is not active.
  /// Always starts a safety timer — cancelled by [_advance] on natural completion.
  /// Prevents the widget from freezing when audio fails silently.
  void _playOrTimer() {
    _fallbackTimer?.cancel();
    if (_adhkar.isEmpty) return;
    final url = _adhkar[_index].audioUrl;
    final isQuranPlaying = context.read<PrayerBloc>().state.isQuranPlaying;
    if (url != null && !isQuranPlaying) {
      _audio.play(url);
      // Safety: fires if onComplete is never received (platform bug / audio focus loss).
      // 2 min covers the longest dhikr file while keeping recovery fast.
      _fallbackTimer = Timer(const Duration(minutes: 2), _advance);
    } else {
      _fallbackTimer = Timer(const Duration(seconds: 20), _advance);
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _completeSub?.cancel();
    _audio.stop();
    _endSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = context.watch<PrayerBloc>().state;
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;
    final dhikr = _adhkar.isEmpty ? null : _adhkar[_index];
    final sessionLabel = widget.session == AdhkarSession.morning
        ? 'أذكار الصباح'
        : 'أذكار المساء';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdhkarCountdownBadge(
          sessionLabel: sessionLabel,
          prayerName: prayerState.nextPrayerName,
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
              key: ValueKey(_index),
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
              '${_index + 1} / ${_adhkar.length}',
              style: TextStyle(fontSize: screenH * 0.020, color: tc.textMuted),
            ),
          ),
      ],
    );
  }
}
