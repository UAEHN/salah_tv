import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/quran_bookmark.dart';
import '../../../domain/entities/surah.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../widgets/mobile/mobile_mushaf_background.dart';
import '../../widgets/mobile/mobile_mushaf_error_view.dart';
import '../../widgets/mobile/mobile_mushaf_index_divider.dart';
import '../../widgets/mobile/mobile_mushaf_landing_header.dart';
import '../../widgets/mobile/mobile_mushaf_open_button.dart';
import '../../widgets/mobile/mobile_mushaf_resume_card.dart';
import '../../widgets/mobile/mobile_mushaf_surah_search_bar.dart';
import '../../widgets/mobile/mobile_mushaf_surah_tile.dart';
import 'mobile_mushaf_reader_screen.dart';

class MobileMushafScreen extends StatefulWidget {
  const MobileMushafScreen({super.key});

  @override
  State<MobileMushafScreen> createState() => _MobileMushafScreenState();
}

class _MobileMushafScreenState extends State<MobileMushafScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<MushafReaderCubit>().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> get _filteredSurahs {
    if (_query.isEmpty) return kSurahs;
    final q = _query.toLowerCase();
    return kSurahs
        .where((s) =>
            s.nameAr.contains(_query) ||
            s.nameEn.toLowerCase().contains(q))
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

  MaterialPageRoute _readerRoute(MushafReaderCubit cubit) =>
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const MobileMushafReaderScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MobileMushafBackground(),
        SafeArea(
          bottom: false,
          child: BlocBuilder<MushafReaderCubit, MushafReaderState>(
            builder: (_, state) {
              if (state.loadStatus == MushafLoadStatus.error) {
                return MobileMushafErrorView(
                  message: state.loadError ??
                      AppLocalizations.of(context).mushafLoadError,
                  onRetry: () => context.read<MushafReaderCubit>().init(),
                );
              }
              return _buildList(state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(MushafReaderState state) {
    final filtered = _filteredSurahs;
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
        const MobileMushafIndexDivider(),
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
      ],
    );
  }
}

