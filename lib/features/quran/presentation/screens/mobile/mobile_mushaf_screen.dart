import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/quran_juz_data.dart';
import '../../../../../core/quran_quick_links.dart';
import '../../../../../core/surahs_data.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../bloc/page_image_download_cubit.dart';
import '../../../domain/entities/quran_bookmark.dart';
import '../../../domain/entities/surah.dart';
import '../../widgets/mobile/mobile_mushaf_background.dart';
import '../../widgets/mobile/mobile_mushaf_error_view.dart';
import '../../widgets/mobile/mobile_mushaf_index_toggle.dart';
import '../../widgets/mobile/mobile_mushaf_juz_tile.dart';
import '../../widgets/mobile/mobile_mushaf_landing_header.dart';
import '../../widgets/mobile/mobile_mushaf_open_button.dart';
import '../../widgets/mobile/mobile_mushaf_quick_links_row.dart';
import '../../widgets/mobile/mobile_mushaf_resume_card.dart';
import '../../widgets/mobile/mobile_mushaf_surah_search_bar.dart';
import '../../widgets/mobile/mobile_mushaf_surah_tile.dart';
import '../../widgets/mobile/mobile_quran_download_banner.dart';
import 'mobile_mushaf_reader_screen.dart';

/// Quran-tab landing page. Pages stream as Madinah PNGs from
/// files.quran.app, so the reader opens instantly — no font gate.
/// The landing surface offers four entry points:
///   * **Resume card** — last bookmark.
///   * **Open Mushaf** — start at page 1.
///   * **Quick links** — Ayah al-Kursi, الكهف, يس, الرحمن, الواقعة,
///     الملك. Single-ayah targets briefly flash a highlight on the
///     destination ayah via [MushafReaderCubit.flashAyah].
///   * **Index toggle** — flip between the surah list and the juz
///     list (1..30 with opening phrase + first page).
class MobileMushafScreen extends StatefulWidget {
  const MobileMushafScreen({super.key});

  @override
  State<MobileMushafScreen> createState() => _MobileMushafScreenState();
}

class _MobileMushafScreenState extends State<MobileMushafScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  MushafIndexMode _indexMode = MushafIndexMode.surahs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> get _filteredSurahs {
    if (_query.isEmpty) return kSurahs;
    final q = _query.toLowerCase();
    return kSurahs
        .where(
          (s) =>
              s.nameAr.contains(_query) || s.nameEn.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _openReader({int? page, QuranBookmark? resume}) async {
    final cubit = context.read<MushafReaderCubit>();
    final navigator = Navigator.of(context);
    await cubit.openReader(page: page, resume: resume);
    if (!mounted) return;
    navigator.push(_readerRoute(cubit));
  }

  Future<void> _openReaderAtSurah(int surahNumber) async {
    final cubit = context.read<MushafReaderCubit>();
    final navigator = Navigator.of(context);
    await cubit.openReader(page: 1);
    if (!mounted) return;
    await cubit.goToSurah(surahNumber);
    if (!mounted) return;
    navigator.push(_readerRoute(cubit));
  }

  Future<void> _openReaderAtQuickLink(QuranQuickLink link) async {
    final cubit = context.read<MushafReaderCubit>();
    final navigator = Navigator.of(context);
    // For ayah-specific links use `quran.getPageNumber` to land
    // directly on the ayah's page (e.g. Ayat al-Kursi → page 42).
    // For whole-surah links fall back to the surah's first page.
    final targetPage = link.ayah != null
        ? quran.getPageNumber(link.surah, link.ayah!)
        : null;
    if (targetPage != null) {
      await cubit.openReader(page: targetPage);
    } else {
      await cubit.openReader(page: 1);
      if (!mounted) return;
      await cubit.goToSurah(link.surah);
    }
    if (!mounted) return;
    navigator.push(_readerRoute(cubit));
    if (!link.isWholeSurah) {
      // Trigger the flash AFTER push so the highlight is visible
      // while the reader screen is on top — the 2-second cubit
      // timer then clears it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cubit.flashAyah(link.surah, link.ayah!);
      });
    }
  }

  MaterialPageRoute _readerRoute(MushafReaderCubit cubit) => MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const MobileMushafReaderScreen(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PageImageDownloadCubit>.value(
      value: GetIt.I<PageImageDownloadCubit>(),
      child: Stack(
        children: [
          const MobileMushafBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const MobileQuranDownloadBanner(),
                Expanded(
                  child: BlocBuilder<MushafReaderCubit, MushafReaderState>(
                    builder: (_, state) {
                      if (state.loadStatus == MushafLoadStatus.error) {
                        return MobileMushafErrorView(
                          message:
                              state.loadError ??
                              AppLocalizations.of(context).mushafLoadError,
                          onRetry: () =>
                              context.read<MushafReaderCubit>().init(),
                        );
                      }
                      return _buildList(state);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(MushafReaderState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
      children: [
        const MobileMushafLandingHeader(),
        if (state.bookmark != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 14),
            child: MobileMushafResumeCard(
              bookmark: state.bookmark!,
              onTap: () => _openReader(resume: state.bookmark),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 18),
          child: MobileMushafOpenButton(onTap: () => _openReader(page: 1)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MobileMushafIndexToggle(
            mode: _indexMode,
            onChanged: (m) => setState(() => _indexMode = m),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MobileMushafQuickLinksRow(onTap: _openReaderAtQuickLink),
        ),
        if (_indexMode == MushafIndexMode.surahs) ..._buildSurahsList(),
        if (_indexMode == MushafIndexMode.juz) ..._buildJuzList(),
      ],
    );
  }

  List<Widget> _buildSurahsList() {
    final filtered = _filteredSurahs;
    return [
      Padding(
        key: const ValueKey('mushaf_search_bar'),
        padding: const EdgeInsets.only(bottom: 12),
        child: MobileMushafSurahSearchBar(
          controller: _searchController,
          onChanged: (q) => setState(() => _query = q),
        ),
      ),
      for (final s in filtered)
        MobileMushafSurahTile(
          key: ValueKey('mushaf_surah_${s.number}'),
          number: s.number,
          onTap: () => _openReaderAtSurah(s.number),
        ),
      if (filtered.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            AppLocalizations.of(context).mushafSearchEmpty,
            textAlign: TextAlign.center,
            style: MobileTextStyles.bodyMd(context),
          ),
        ),
    ];
  }

  List<Widget> _buildJuzList() {
    return [
      for (final j in kJuzList)
        MobileMushafJuzTile(
          key: ValueKey('mushaf_juz_${j.number}'),
          juz: j,
          onTap: () => _openReader(page: j.firstPage),
        ),
    ];
  }
}
