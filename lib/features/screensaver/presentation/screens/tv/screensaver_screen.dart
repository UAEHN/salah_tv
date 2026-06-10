import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/app_colors.dart';
import '../../../domain/i_screensaver_repository.dart';
import '../../bloc/screensaver_cubit.dart';
import '../../bloc/screensaver_state.dart';
import '../../widgets/screensaver_background.dart';
import '../../widgets/screensaver_clock.dart';
import '../../widgets/screensaver_countdown.dart';
import '../../widgets/screensaver_slide_view.dart';

/// Ambient Islamic screensaver: a calm full-screen rotation of verses, hadith
/// and adhkar over a slowly-breathing dark backdrop. Self-provides its cubit so
/// callers only render `ScreensaverScreen(palette: ...)`.
class ScreensaverScreen extends StatelessWidget {
  final AccentPalette palette;

  const ScreensaverScreen({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ScreensaverCubit(GetIt.I<IScreensaverRepository>())..start(),
      child: _Shell(palette: palette),
    );
  }
}

class _Shell extends StatefulWidget {
  final AccentPalette palette;
  const _Shell({required this.palette});

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> with SingleTickerProviderStateMixin {
  late final AnimationController _ambient; // disposed in dispose()

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScreensaverBackground(animation: _ambient, palette: widget.palette),
        // Text stays fixed and centred; only the content cross-fades between
        // slides. The background alone carries the ambient motion.
        BlocBuilder<ScreensaverCubit, ScreensaverState>(
          builder: (context, state) {
            if (state.isEmpty) return const SizedBox.shrink();
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: ScreensaverSlideView(
                key: ValueKey(state.index),
                item: state.current,
                palette: widget.palette,
              ),
            );
          },
        ),
        Positioned(
          left: 60,
          bottom: 44,
          child: ScreensaverClock(color: Colors.white.withValues(alpha: 0.55)),
        ),
        const Positioned(right: 60, bottom: 44, child: ScreensaverCountdown()),
      ],
    );
  }
}
