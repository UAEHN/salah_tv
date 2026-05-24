import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import '../../bloc/page_image_download_cubit.dart';
import 'mobile_mushaf_continuous_section.dart';
import 'mobile_mushaf_reciter_section.dart';
import 'mobile_mushaf_storage_section.dart';
import 'mobile_mushaf_theme_section.dart';

/// Bottom sheet that exposes all reader preferences.
/// Each section lives in its own file (CLAUDE.md §4 SRP + 150-line cap).
///
/// The "Delete font bundle" row was removed during the QCF → image
/// engine pivot — pages now stream as PNGs from android.quran.com, so
/// there is no on-disk font bundle for the user to manage.
class MobileMushafSettingsSheet extends StatelessWidget {
  const MobileMushafSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final readerCubit = context.read<MushafReaderCubit>();
    final downloadCubit = GetIt.I<PageImageDownloadCubit>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: readerCubit),
          BlocProvider.value(value: downloadCubit),
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
                const SizedBox(height: 18),
                MobileMushafContinuousSection(enabled: state.continuousPlayback),
                const SizedBox(height: 18),
                MobileMushafReciterSection(reciterId: state.prefs.reciterId),
                const SizedBox(height: 18),
                const MobileMushafStorageSection(),
              ],
            ),
          ),
        );
      },
    );
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
