import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../widgets/mobile/mobile_mushaf_app_bar.dart';
import '../../widgets/mobile/mobile_mushaf_intro_sheet.dart';
import '../../widgets/mobile/mobile_mushaf_page_jump_dialog.dart';
import '../../widgets/mobile/mobile_mushaf_playing_bar.dart';
import '../../widgets/mobile/mobile_mushaf_reader_pages.dart';
import '../../widgets/mobile/mobile_mushaf_settings_sheet.dart';
import '../../widgets/mobile/mobile_mushaf_surah_index_sheet.dart';

class MobileMushafReaderScreen extends StatefulWidget {
  const MobileMushafReaderScreen({super.key});

  @override
  State<MobileMushafReaderScreen> createState() =>
      _MobileMushafReaderScreenState();
}

class _MobileMushafReaderScreenState extends State<MobileMushafReaderScreen> {
  late final PageController _controller;
  late final MushafReaderCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MushafReaderCubit>();
    _controller = PageController(initialPage: _cubit.state.currentPage - 1);
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowIntro());
  }

  Future<void> _maybeShowIntro() async {
    if (!mounted) return;
    if (_cubit.state.hasSeenIntro) return;
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

  void _onAyahTap(Ayah a) => _cubit.tapAyah(a.surahNumber, a.numberInSurah);

  void _togglePauseResume() {
    final s = _cubit.state.playingSurah;
    final a = _cubit.state.playingAyah;
    if (s != null && a != null) _cubit.tapAyah(s, a);
  }

  Future<void> _saveWithToast() async {
    await _cubit.saveBookmark();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).mushafBookmarkSaved)),
    );
  }

  void _onPageChanged(int i) {
    if (_cubit.state.currentPage != i + 1) _cubit.goToPage(i + 1);
  }

  void _syncControllerToState(MushafReaderState state) {
    if (!_controller.hasClients) return;
    final wanted = state.currentPage - 1;
    if (_controller.page?.round() == wanted) return;
    _controller.animateToPage(
      wanted,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MushafReaderCubit, MushafReaderState>(
      listenWhen: (p, n) =>
          p.audioStatus != n.audioStatus || p.currentPage != n.currentPage,
      listener: (context, state) {
        if (state.audioStatus == MushafAudioStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).mushafAudioError),
            ),
          );
        }
        _syncControllerToState(state);
      },
      builder: (_, state) {
        final palette = ReadingPalette.of(state.readingTheme);
        return Scaffold(
          backgroundColor: palette.screenBg,
          appBar: MobileMushafAppBar(
            page: state.currentPageData,
            readingTheme: state.readingTheme,
            onBack: () => Navigator.of(context).pop(),
            onOpenSurahIndex: _openSurahIndex,
            onOpenPageJump: _openPageJump,
            onOpenSettings: () => MobileMushafSettingsSheet.show(context),
            onSaveBookmark: _saveWithToast,
            onShowIntro: _showIntroManually,
          ),
          body: Column(
            children: [
              Expanded(
                child: MobileMushafReaderPages(
                  state: state,
                  palette: palette,
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  onAyahTap: _onAyahTap,
                ),
              ),
              MobileMushafPlayingBar(
                state: state,
                onTogglePauseResume: _togglePauseResume,
                onStop: _cubit.stopAudio,
              ),
            ],
          ),
        );
      },
    );
  }
}
