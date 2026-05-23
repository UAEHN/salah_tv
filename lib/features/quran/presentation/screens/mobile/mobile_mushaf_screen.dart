import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../../../injection.dart';
import '../../../domain/entities/quran_bookmark.dart';
import '../../../domain/entities/surah.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../bloc/quran_assets_cubit.dart';
import '../../bloc/quran_assets_state.dart';
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

/// Slim status strip pinned above the surah list. While downloading
/// it shows progress; once the bundle is on disk it shows a small
/// "Mushaf ready" row with a delete action so the user can free the
/// ~105 MB without having to enter the reader.
class _DownloadBanner extends StatelessWidget {
  const _DownloadBanner();

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final cubit = context.read<QuranAssetsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.quranAssetsDeleteTitle),
        content: Text(l.quranAssetsDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.quranAssetsCancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.quranAssetsDelete)),
        ],
      ),
    );
    if (ok != true) return;
    await cubit.deleteBundle();
    messenger.showSnackBar(SnackBar(content: Text(l.quranAssetsDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<QuranAssetsCubit, QuranAssetsState>(
      buildWhen: (p, n) =>
          p.status != n.status || p.downloadedCount != n.downloadedCount,
      builder: (context, state) {
        if (state.status == QuranAssetsStatus.ready) {
          return _ReadyRow(
            label: l.quranAssetsReady,
            deleteLabel: l.quranAssetsDeleteTitle,
            onDelete: () => _confirmAndDelete(context),
          );
        }
        if (state.status != QuranAssetsStatus.downloading) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_download_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.quranAssetsDownloadingTitle,
                        style: MobileTextStyles.bodyMd(context)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    l.quranAssetsDownloadProgress(
                        state.downloadedCount, state.totalCount),
                    style: MobileTextStyles.bodyMd(context)
                        .copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: state.progress, minHeight: 4),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadyRow extends StatelessWidget {
  final String label;
  final String deleteLabel;
  final VoidCallback onDelete;
  const _ReadyRow({
    required this.label,
    required this.deleteLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final faint = MobileColors.onSurfaceFaint(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: MobileTextStyles.bodyMd(context)
                    .copyWith(fontSize: 13, color: faint)),
          ),
          TextButton.icon(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                size: 18, color: Theme.of(context).colorScheme.error),
            label: Text(deleteLabel,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMushafScreenState extends State<MobileMushafScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<MushafReaderCubit>().init();
    // Probe the asset bundle on first landing-screen mount so the
    // download banner can surface here too, not only on the gate.
    final assets = getIt<QuranAssetsCubit>();
    if (assets.state.status == QuranAssetsStatus.unknown) assets.probe();
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
    return BlocProvider.value(
      value: getIt<QuranAssetsCubit>(),
      child: Stack(
        children: [
          const MobileMushafBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _DownloadBanner(),
                Expanded(
                  child:
                      BlocBuilder<MushafReaderCubit, MushafReaderState>(
                    builder: (_, state) {
                      if (state.loadStatus == MushafLoadStatus.error) {
                        return MobileMushafErrorView(
                          message: state.loadError ??
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

