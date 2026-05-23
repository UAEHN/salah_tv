import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../bloc/quran_assets_cubit.dart';
import '../../bloc/quran_assets_state.dart';
import 'mobile_mushaf_continuous_section.dart';
import 'mobile_mushaf_font_section.dart';
import 'mobile_mushaf_reciter_section.dart';
import 'mobile_mushaf_theme_section.dart';

/// Bottom sheet that exposes all reader preferences.
/// Each section lives in its own file (CLAUDE.md §4 SRP + 150-line cap).
class MobileMushafSettingsSheet extends StatelessWidget {
  const MobileMushafSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final readerCubit = context.read<MushafReaderCubit>();
    final assetsCubit = context.read<QuranAssetsCubit>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: readerCubit),
          BlocProvider.value(value: assetsCubit),
        ],
        child: const MobileMushafSettingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MushafReaderCubit, MushafReaderState>(
      builder: (context, state) {
        final viewInset = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: MobileColors.cardColor(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: viewInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GrabHandle(),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).mushafReadingSettings,
                  style: MobileTextStyles.titleMd(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                MobileMushafThemeSection(theme: state.readingTheme),
                const SizedBox(height: 20),
                MobileMushafFontSection(size: state.fontSize),
                const SizedBox(height: 12),
                MobileMushafContinuousSection(enabled: state.continuousPlayback),
                const SizedBox(height: 18),
                MobileMushafReciterSection(reciterId: state.prefs.reciterId),
                const SizedBox(height: 18),
                const _DeleteBundleButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Removes the downloaded QCF v2 font bundle (~105 MB on disk). The
/// reader stays usable in-session — Flutter has no font-unregister API
/// — but the gate UI shows the download prompt again on next launch.
class _DeleteBundleButton extends StatelessWidget {
  const _DeleteBundleButton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<QuranAssetsCubit, QuranAssetsState>(
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, state) {
        final ready = state.status == QuranAssetsStatus.ready;
        return OutlinedButton.icon(
          icon: Icon(Icons.delete_outline_rounded,
              color: theme.colorScheme.error),
          label: Text(l.quranAssetsDeleteTitle,
              style: TextStyle(color: theme.colorScheme.error)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: ready ? () => _confirmAndDelete(context) : null,
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final cubit = context.read<QuranAssetsCubit>();
    final scaffold = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
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
    if (confirm != true) return;
    await cubit.deleteBundle();
    scaffold.showSnackBar(SnackBar(content: Text(l.quranAssetsDeleted)));
  }
}

class _GrabHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: MobileColors.onSurfaceFaint(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
