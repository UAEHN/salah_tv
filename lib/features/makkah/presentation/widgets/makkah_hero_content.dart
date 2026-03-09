import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/time_formatters.dart';
import '../../../prayer/presentation/prayer_provider.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../makkah_stream_controller.dart';
import 'makkah_video_overlay.dart';

/// Replaces [_NextPrayerContent] inside HeroCard when the Makkah stream is
/// active. Shows the live video with prayer name + countdown overlaid.
class MakkahHeroContent extends StatefulWidget {
  const MakkahHeroContent({super.key});

  @override
  State<MakkahHeroContent> createState() => _MakkahHeroContentState();
}

class _MakkahHeroContentState extends State<MakkahHeroContent> {
  late final MakkahStreamController _stream;
  late final PrayerProvider _prayerProv;
  bool? _lastAudioEnabled;

  @override
  void initState() {
    super.initState();
    _stream = MakkahStreamController();
    _prayerProv = context.read<PrayerProvider>();
    // Defer ExoPlayer init to after the current frame so the Android UI thread
    // is free — prevents the 1–5 s rendering freeze on low-end TV boxes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _stream.initialize();
    });
  }

  @override
  void dispose() {
    _prayerProv.setMakkahStreamAudioActive(false);
    _stream.dispose();
    super.dispose();
  }

  void _toggleMute(BuildContext context) {
    _stream.toggleMute();
    final isNowMuted = _stream.isMuted.value;
    context.read<PrayerProvider>().setMakkahStreamAudioActive(!isNowMuted);
  }

  @override
  Widget build(BuildContext context) {
    final audioEnabled = context.select(
      (SettingsProvider p) => p.settings.isMakkahStreamAudioEnabled,
    );
    _stream.setMuted(!audioEnabled);
    // Sync Quran pause/resume only when the audio setting actually changes.
    if (_lastAudioEnabled != audioEnabled) {
      _lastAudioEnabled = audioEnabled;
      _prayerProv.setMakkahStreamAudioActive(audioEnabled);
    }

    final prayer = context.watch<PrayerProvider>();
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
                  child: _PrayerTextOverlay(prayer: prayer, screenH: screenH),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrayerTextOverlay extends StatelessWidget {
  final PrayerProvider prayer;
  final double screenH;

  const _PrayerTextOverlay({required this.prayer, required this.screenH});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'الصلاة القادمة',
          style: TextStyle(
            fontSize: screenH * 0.038,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          prayer.nextPrayerName,
          style: TextStyle(
            fontSize: screenH * 0.10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 12)],
          ),
        ),
        SizedBox(height: screenH * 0.005),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            formatCountdown(prayer.countdown),
            style: TextStyle(
              fontSize: screenH * 0.075,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }
}
