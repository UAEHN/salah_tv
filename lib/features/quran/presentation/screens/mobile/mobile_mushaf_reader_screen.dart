import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../domain/entities/reading_theme.dart';
import '../../../domain/i_ayah_bounds_repository.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../widgets/mobile/mobile_mushaf_intro_sheet.dart';
import '../../widgets/mobile/mobile_mushaf_page.dart';
import '../../widgets/mobile/mobile_mushaf_page_jump_dialog.dart';
import '../../widgets/mobile/mobile_mushaf_playing_bar.dart';
import '../../widgets/mobile/mobile_mushaf_settings_sheet.dart';
import '../../widgets/mobile/mobile_mushaf_surah_index_sheet.dart';

/// Full Mushaf reader. The Scaffold has no AppBar and no BlocConsumer
/// at the body level. State subscriptions are pushed to:
///   • a top-level `BlocSelector<ReadingTheme>` that rebuilds the
///     Scaffold only when the user switches paper/sepia/night;
///   • two `BlocListener`s for audio-error toasts and external page
///     jumps (surah index / page-jump dialog) — never fight a user
///     swipe thanks to the [_swipeOriginated] flag;
///   • a narrow `BlocBuilder` around the playing-bar overlay only.
///
/// Pages are rendered as PNG images from android.quran.com (see
/// `project_quran_engine_pivot` memory). No font gate, no QCF
/// bundle — `CachedNetworkImage` inside each page handles loading.
class MobileMushafReaderScreen extends StatefulWidget {
  const MobileMushafReaderScreen({super.key});

  @override
  State<MobileMushafReaderScreen> createState() =>
      _MobileMushafReaderScreenState();
}

class _MobileMushafReaderScreenState extends State<MobileMushafReaderScreen> {
  late final PageController _controller;
  late final MushafReaderCubit _cubit;
  bool _swipeOriginated = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MushafReaderCubit>();
    _controller = PageController(initialPage: _cubit.state.currentPage - 1);
    WakelockPlus.enable();
    // Fire-and-forget: kick the 2.2 MB ayahinfo SQLite download so
    // tap-to-play is ready by the time the user picks a verse.
    // Repository is idempotent; calling on every reader open is fine.
    GetIt.I<IAyahBoundsRepository>().ensureReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowIntro();
    });
  }

  Future<void> _maybeShowIntro() async {
    if (!mounted || _cubit.state.hasSeenIntro) return;
    await MobileMushafIntroSheet.show(context);
    await _cubit.markIntroSeen();
  }

  Future<void> _showIntroManually() => MobileMushafIntroSheet.show(context);

  @override
  void dispose() {
    _cubit.onLeaveReader();
    WakelockPlus.disable();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSurahIndex() async {
    final picked = await MobileMushafSurahIndexSheet.show(context);
    if (picked == null || !mounted) return;
    await _cubit.goToSurah(picked);
  }

  Future<void> _openPageJump() async {
    final picked = await MobileMushafPageJumpDialog.show(context);
    if (picked == null || !mounted) return;
    await _cubit.goToPage(picked);
  }

  Future<void> _saveWithToast() async {
    await _cubit.saveBookmark();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).mushafBookmarkSaved)));
  }

  void _onPageChanged(int i) {
    if (_cubit.state.currentPage == i + 1) return;
    _swipeOriginated = true;
    _cubit.goToPage(i + 1);
  }

  void _syncControllerToState(MushafReaderState state) {
    if (_swipeOriginated) {
      _swipeOriginated = false;
      return;
    }
    if (!_controller.hasClients) return;
    final wanted = state.currentPage - 1;
    if (_controller.page?.round() == wanted) return;
    _controller.animateToPage(wanted,
        duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MushafReaderCubit, MushafReaderState>(
          listenWhen: (p, n) =>
              p.audioStatus != n.audioStatus &&
              n.audioStatus == MushafAudioStatus.error,
          listener: (ctx, _) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(ctx).mushafAudioError))),
        ),
        BlocListener<MushafReaderCubit, MushafReaderState>(
          listenWhen: (p, n) => p.currentPage != n.currentPage,
          listener: (_, state) => _syncControllerToState(state),
        ),
      ],
      child: BlocSelector<MushafReaderCubit, MushafReaderState, ReadingTheme>(
        selector: (s) => s.readingTheme,
        builder: (_, theme) {
          final palette = ReadingPalette.of(theme);
          return Scaffold(
            backgroundColor: palette.screenBg,
            // Column layout (not Stack overlay) so the playing bar
            // takes its own slot. When the bar appears, the PageView
            // shrinks by the bar's height — the bottom ayah of the
            // current page stays visible above the bar instead of
            // being hidden behind it.
            body: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    reverse: true,
                    itemCount: 604,
                    allowImplicitScrolling: true,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, i) => RepaintBoundary(
                      child: MobileMushafPage(
                        pageNumber: i + 1,
                        palette: palette,
                        onBack: () => Navigator.of(context).pop(),
                        onOpenSurahIndex: _openSurahIndex,
                        onOpenPageJump: _openPageJump,
                        onSaveBookmark: _saveWithToast,
                        onSettings: () =>
                            MobileMushafSettingsSheet.show(context),
                        onShowIntro: _showIntroManually,
                        onAyahTap: _cubit.tapAyah,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<MushafReaderCubit, MushafReaderState>(
                  buildWhen: (p, n) =>
                      p.audioStatus != n.audioStatus ||
                      p.playingSurah != n.playingSurah ||
                      p.playingAyah != n.playingAyah,
                  builder: (_, state) => MobileMushafPlayingBar(
                    state: state,
                    onTogglePauseResume: () {
                      final s = state.playingSurah;
                      final a = state.playingAyah;
                      if (s != null && a != null) _cubit.tapAyah(s, a);
                    },
                    onStop: _cubit.stopAudio,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
