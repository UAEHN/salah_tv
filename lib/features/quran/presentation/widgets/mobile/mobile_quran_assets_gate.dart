import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/quran_assets_cubit.dart';
import '../../bloc/quran_assets_state.dart';

/// Gate widget. While the QCF v2 font bundle is missing or
/// downloading, this surface replaces the reader UI; once
/// [QuranAssetsStatus.ready] it lets [child] (the actual reader)
/// through unchanged.
class MobileQuranAssetsGate extends StatefulWidget {
  final Widget child;
  const MobileQuranAssetsGate({super.key, required this.child});

  @override
  State<MobileQuranAssetsGate> createState() => _MobileQuranAssetsGateState();
}

class _MobileQuranAssetsGateState extends State<MobileQuranAssetsGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<QuranAssetsCubit>();
      if (cubit.state.status == QuranAssetsStatus.unknown) cubit.probe();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranAssetsCubit, QuranAssetsState>(
      buildWhen: (p, n) =>
          p.status != n.status || p.downloadedCount != n.downloadedCount,
      builder: (context, state) {
        if (state.status == QuranAssetsStatus.ready) return widget.child;
        if (state.status == QuranAssetsStatus.unknown) {
          // First frame after open: probe is in flight. Show a neutral
          // loading surface instead of the "Download" prompt so the
          // user doesn't see download UI flash before the gate learns
          // that the bundle is already on disk from a previous session.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(child: _Body(state: state)),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final QuranAssetsState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDownloading = state.status == QuranAssetsStatus.downloading;
    final isDeleting = state.status == QuranAssetsStatus.deleting;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded,
                size: 72, color: MobileColors.onSurfaceFaint(context)),
            const SizedBox(height: 18),
            Text(
              isDownloading
                  ? l.quranAssetsDownloadingTitle
                  : l.quranAssetsDownloadTitle,
              style: MobileTextStyles.headlineMd(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDownloading
                  ? l.quranAssetsDownloadProgress(
                      state.downloadedCount, state.totalCount)
                  : l.quranAssetsDownloadSize,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurfaceMuted(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isDownloading) ...[
              LinearProgressIndicator(value: state.progress),
              const SizedBox(height: 14),
              Text(
                l.quranAssetsBackgroundHint,
                style: TextStyle(
                  fontSize: 12,
                  color: MobileColors.onSurfaceFaint(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
            ],
            if (state.error != null && !isDownloading) ...[
              Text(state.error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              icon: Icon(isDownloading
                  ? Icons.close_rounded
                  : Icons.download_rounded),
              label: Text(isDownloading
                  ? l.quranAssetsCancel
                  : (state.error != null
                      ? l.quranAssetsRetry
                      : l.quranAssetsDownloadButton)),
              onPressed: isDeleting
                  ? null
                  : () {
                      final cubit = context.read<QuranAssetsCubit>();
                      if (isDownloading) {
                        cubit.cancelDownload();
                      } else {
                        cubit.startDownload();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
