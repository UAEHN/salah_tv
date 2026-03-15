import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../makkah_stream_controller.dart';
import 'makkah_video_overlay.dart';
import 'prayer_text_overlay.dart';

/// Replaces [_NextPrayerContent] inside HeroCard when the Makkah stream is
/// active. Shows the live video with prayer name + countdown overlaid.
class MakkahHeroContent extends StatefulWidget {
  const MakkahHeroContent({super.key});

  @override
  State<MakkahHeroContent> createState() => _MakkahHeroContentState();
}

class _MakkahHeroContentState extends State<MakkahHeroContent> {
  late final MakkahStreamController _stream;
  late final PrayerBloc _prayerBloc;
  SettingsProvider? _sp;
  bool? _isLastAudioEnabled;

  @override
  void initState() {
    super.initState();
    _stream = MakkahStreamController();
    _prayerBloc = context.read<PrayerBloc>();
    // Defer ExoPlayer init to after the current frame so the Android UI thread
    // is free — prevents the 1–5 s rendering freeze on low-end TV boxes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _stream.initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sp = context.read<SettingsProvider>();
    if (_sp != sp) {
      _sp?.removeListener(_syncAudio);
      _sp = sp;
      sp.addListener(_syncAudio);
      _syncAudio();
    }
  }

  /// Syncs mute state and notifies BLoC when the audio setting changes.
  /// Called from a ChangeNotifier listener — never from build().
  void _syncAudio() {
    if (!mounted) return;
    final audioEnabled = _sp!.settings.isMakkahStreamAudioEnabled;
    _stream.setMuted(!audioEnabled);
    if (_isLastAudioEnabled != audioEnabled) {
      _isLastAudioEnabled = audioEnabled;
      _prayerBloc.add(PrayerMakkahStreamAudioChanged(audioEnabled));
    }
  }

  @override
  void dispose() {
    _sp?.removeListener(_syncAudio);
    _prayerBloc.add(const PrayerMakkahStreamAudioChanged(false));
    _stream.dispose();
    super.dispose();
  }

  void _toggleMute(BuildContext context) {
    _stream.toggleMute();
    final isNowMuted = _stream.isMuted.value;
    context.read<PrayerBloc>().add(PrayerMakkahStreamAudioChanged(!isNowMuted));
  }

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerBloc>().state;
    final screenH = MediaQuery.of(context).size.height;

    return Focus(
      autofocus: false,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          _toggleMute(context);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: ValueListenableBuilder<MakkahStreamState>(
        valueListenable: _stream.state,
        builder: (context, state, _) {
          if (state != MakkahStreamState.playing ||
              _stream.controller == null) {
            // Stream not ready — show nothing; _NextPrayerContent shows through.
            return const SizedBox.shrink();
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Live video — cover fit.
                // Fixed 1920×1080 avoids Size.zero on live-stream init
                // (ExoPlayer reports size=0 until the first frame is decoded).
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 1920,
                      height: 1080,
                      child: VideoPlayer(_stream.controller!),
                    ),
                  ),
                ),
                // Gradient + live badge
                const MakkahVideoOverlay(),
                // Prayer name + countdown overlay at bottom-center
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: screenH * 0.03,
                  child: PrayerTextOverlay(prayer: prayer, screenH: screenH),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
